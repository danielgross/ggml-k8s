import os
import yaml
from urllib.parse import urlparse
from pathlib import Path
import argparse
parser = argparse.ArgumentParser()

# Argument parser setup
parser = argparse.ArgumentParser(description="Process models and generate Kubernetes configuration.")
parser.add_argument('--acm_certificate_arn', required=True, help='ARN of the ACM Certificate')
parser.add_argument('--domain', required=True, help='Domain for the ingress resource')
args = parser.parse_args()

# Assign the parsed arguments to variables
ACM_CERTIFICATE_ARN = args.acm_certificate_arn
DOMAIN = args.domain

# Load the input and output files
yaml_output_path = 'kubernetes/values.yaml'
with open("models.yaml", 'r') as file:
    input_yaml = yaml.safe_load(file)
with open("_scripts/template.yaml", 'r') as file:
    template_yaml = yaml.safe_load(file)

# Extract the models section from input YAML
models_input = input_yaml.get('models', [])

# Processed models list
models_processed = []

for model in models_input:
    # Extract base name from URL
    model_name = Path(urlparse(model['url']).path).name
    sanitized_name = Path(urlparse(model['url']).path).stem.replace('.', '-').replace('_', '-').lower()
    cpu_request = int(model.get('resources', {}).get('requests', {}).get('cpu', '8192m').rstrip('m'))

    # Adjust limits and requests based on CPU requests
    model_dict = {
        'name': sanitized_name,
        'url': model['url'],
        'threads': round(cpu_request/1000)*2,
        'replicaCount': 1,
        'resources': {
            'limits': {
                'cpu': f'{cpu_request*2}m',
                'memory': f'{cpu_request*4}Mi',
                'ephemeral-storage': f'{(round(cpu_request / 100)+1)*2}Gi'
            },
            'requests': model.get('resources', {}).get('requests', {})
        }
    }
    model_dict['resources']['requests']['ephemeral-storage'] = f'{(round(cpu_request / 100)+1)}Gi'
    if model.get('promptTemplate', "") != "":
        model_dict['promptTemplate'] = {}
        model_dict['promptTemplate'][model_name + '.tmpl'] = model.get('promptTemplate', "").strip()
    models_processed.append(model_dict)

# Add processed models to the template
template_yaml['models'] = models_processed

# Update the template YAML with the new arguments
template_yaml['ingress']['annotations']['alb.ingress.kubernetes.io/certificate-arn'] = ACM_CERTIFICATE_ARN
template_yaml['ingress']['hosts'][0]['host'] = "api." + DOMAIN

# Use the OG volumeHandle for the PVC. This should derive from the terraform apply output on the 15th EFS resource
# TODO: Make this cleaner and more robust
if os.path.exists(yaml_output_path):
    with open(yaml_output_path, 'r') as file:
        volumeHandle = yaml.safe_load(file)['persistence']['pvc']['volumeHandle']
    template_yaml['persistence']['pvc']['volumeHandle'] = volumeHandle

# Save the processed YAML to output path
with open(yaml_output_path, 'w') as file:
    yaml.dump(template_yaml, file, sort_keys=False)
