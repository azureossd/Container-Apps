using Microsoft.AspNetCore.Mvc;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

namespace ASPNETMSI.Controllers
{
    public class ManagedIdentityController : Controller
    {
        private readonly ILogger _logger;
        private readonly IConfiguration _config;

        public ManagedIdentityController(ILogger<ManagedIdentityController> logger, IConfiguration config)
        {
            _logger = logger;
            _config = config;
        }

        public async Task<IActionResult> System()
        {
            string AZURE_KEYVAULT_RESOURCEENDPOINT = _config["AZURE_KEYVAULT_RESOURCEENDPOINT"];

            var credential = new ManagedIdentityCredential();

            var client = new SecretClient(vaultUri: new Uri(AZURE_KEYVAULT_RESOURCEENDPOINT), credential);

            try
            {
                KeyVaultSecret secret = await client.GetSecretAsync("secret1");
                ViewBag.Result = "My secret is: " + secret.Value;
            }
            catch (Exception e)
            {
                ViewBag.Result = $"Authentication Failed.";
                _logger.LogError($"Authentication Failed for System Managed Identity. {e.Message}");
            }
            return View();
        }

        public async Task<IActionResult> User()
        {
            string AZURE_KEYVAULT_RESOURCEENDPOINT = _config["AZURE_KEYVAULT_RESOURCEENDPOINT"];
            string CLIENTID = _config["CLIENTID"];

            var credential = new ManagedIdentityCredential(CLIENTID);

            var client = new SecretClient(vaultUri: new Uri(AZURE_KEYVAULT_RESOURCEENDPOINT), credential);

            try
            {
                KeyVaultSecret secret = await client.GetSecretAsync("secret2");
                ViewBag.Result = "My secret is: " + secret.Value;
            }
            catch (Exception e)
            {
                ViewBag.Result = $"Authentication Failed.";
                _logger.LogError($"Authentication Failed for User Managed Identity. {e.Message}");
            }

            return View();
        }
    }
}
