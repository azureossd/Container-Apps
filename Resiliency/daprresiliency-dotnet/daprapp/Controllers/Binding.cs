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

namespace daprapp.Controllers
{
    public class Binding : Controller
    {
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


                Console.WriteLine("/mybindingforinput controller was triggered via Dapr input binding. Message data: {0}", body);

                string DAPR_STORE_NAME = "mystatestore";
                //The following lines of code use DaprClient SDK to write the data from the input binding to the state store.
                var daprClient = new DaprClientBuilder().Build();

                try
                {
                    await daprClient.SaveStateAsync(DAPR_STORE_NAME, "frominputbinding", body);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Exception when trying to write to state store" + ex.ToString());
                }
            }

            // Acknowledge request
            return Ok();
        }
    }
}
