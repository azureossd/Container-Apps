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
    public class StateController : Controller
    {
        public async Task<IActionResult> StateStore()
        {
            string DAPR_STORE_NAME = "mystatestore";
            var daprClient = new DaprClientBuilder().Build();

            Random random = new Random();
            int randomNumber = random.Next(1, 1000);

            ViewBag.valueToStateStore = randomNumber.ToString();

            try
            {
                await daprClient.SaveStateAsync(DAPR_STORE_NAME, "fakekey", randomNumber.ToString());
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception when trying to write to state store" + ex.ToString());
                ViewBag.valueToStateStore = "An error occurred when trying to write to the state store.";
            }

            try
            {
                var result = await daprClient.GetStateAsync<string>(DAPR_STORE_NAME, "fakekey");
                ViewBag.valuefromStateStore = result;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception when trying to read from state store" + ex.ToString());
                ViewBag.valuefromStateStore = "An error occurred when trying to read from the state store.";
            }

            try
            {
                var result = await daprClient.GetStateAsync<string>(DAPR_STORE_NAME, "frominputbinding");
                if (result != null && result != "")
                {
                    ViewBag.valuefromInputBindingToStateStore = result;
                }
                else
                {
                    ViewBag.valuefromInputBindingToStateStore = "Not applicable. Binding was not triggered";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception when trying to read from state store" + ex.ToString());
                ViewBag.valuefromStateStore = "An error occurred when trying to read from the state store.";
            }

            return View();
        }
    }
}
