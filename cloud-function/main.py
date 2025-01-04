import functions_framework
import os

@functions_framework.http
def handler(request):    
    vm_private_ip = os.environ['VM_PRIVATE_IP']
    url = "http://"+vm_private_ip+"/index.html"
    response  = requests.get(url)
    return response.text