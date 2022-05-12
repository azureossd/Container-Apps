import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({ "message": "azure-webapps-linux-python-flask-msi-containerapps" })

@app.route("/api/kv")
def get_keyvault_secret():
    client_id = os.environ["AZURE_CLIENT_ID"]
    key_vault_name = os.environ["KEY_VAULT_NAME"]
    secret_name = os.environ["SECRET_NAME"]
    kv_uri = f"https://{key_vault_name}.vault.azure.net"

    credential = DefaultAzureCredential(managed_identity_client_id=client_id)
    client = SecretClient(vault_url=kv_uri, credential=credential)

    print(f"Retrieving your secret from {key_vault_name}.")

    retrieved_secret = client.get_secret(secret_name)

    print(f"Your secret is '{retrieved_secret.value}'.")
    print("Done.")

    return jsonify({ "message": retrieved_secret.value })