using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Client;
using System.Text.Json.Serialization;
using System.IO;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using System.Text.Encodings.Web;
using System.Text.Unicode;

namespace binding_example_dotnet_sdk.Controllers
{
    public class Binding : Controller
    {
        //The code in this method uses DaprClient SDK to make a request to a Dapr binding endpoint. In this manner, you are using the Dapr component as an output binding, to send a message to the provider.
        // You will need to send a request to this route.

        //Non-Dapr http route.
        //This route will make a request to the Dapr binding route for mybindingforoutput, which will invoke the specified output binding. You can make a direct request to this route if you want to test the output binding without having to first trigger the input binding.
        [HttpGet]
        public async Task<IActionResult> MyRoute()
        {
            Console.WriteLine("executing myroute");
            var message = "MyRoute method wrote to the output binding at " + DateTime.UtcNow;

            //The following lines of code use DaprClient SDK to make a request to the Dapr binding route for mybindingforoutput, which will invoke the specified output binding.
            var daprClient = new DaprClientBuilder().Build();
            await daprClient.InvokeBindingAsync("mybindingforoutput", "create", message);

            return View();
        }

        //For input bindings, can't use Dapr SDK. This is a non-Dapr REST controller
        //The name of this controller matches the metadata name of a Dapr binding component
        //Dapr will automatically make a request to this route when it detects a message in the provider you specify in the mybindingforinput Dapr binding component

        [HttpPost("/mybindingforinput")]
        //[Produces("application/json")]
        public async Task<IActionResult> Post()
        {
            Request.EnableBuffering();

            Request.Body.Position = 0;
            using (var reader = new StreamReader(Request.Body))
            {
                var body = await reader.ReadToEndAsync();
                string jsonString = JsonSerializer.Serialize(body);

                var unescaped = System.Text.RegularExpressions.Regex.Unescape(jsonString);

                Console.WriteLine("/mybindingforinput controller was triggered via Dapr input binding. Message data: {0}", unescaped);

                //The following lines of code use DaprClient SDK to make a request to the Dapr binding route for mybindingforoutput, which will invoke the specified output binding.
                var daprClient = new DaprClientBuilder().Build();
                await daprClient.InvokeBindingAsync("mybindingforoutput", "create", unescaped);
            }

            // Acknowledge request
            return Ok();
        }
    }
}
