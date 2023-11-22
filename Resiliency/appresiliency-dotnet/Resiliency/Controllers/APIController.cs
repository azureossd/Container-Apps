using Resiliency.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Client;
using System.Threading;
using System.Net.Http;
using Newtonsoft.Json.Linq;
using Microsoft.Extensions.Primitives;
using Microsoft.AspNetCore.Http.Headers;

namespace Resiliency.Controllers
{
    public class APIController : ControllerBase
    {
        private readonly ILogger<APIController> _logger;
		
	    DaprClient _daprClient = new DaprClientBuilder().Build();

        const string DAPR_STORE_NAME = "mystatestore";

        const string INGRESS_HTTP_CURRENT_TRIES_KEY = "INGRESS_HTTP_CURRENT_TRIES_KEY";

        const int initialTryCount = 0;

        const int httpMaxRetries = 3;

        private static HttpClient httpClient = new HttpClient();

        public APIController(ILogger<APIController> logger)
        {
            _logger = logger;
        }

        public async Task<IActionResult> RetryCount()
        {
            try
            {
                var fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);

                if (fakeval == null || fakeval == "" || !Int32.TryParse(fakeval, out int j))
                {
                    await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, initialTryCount.ToString());
                    fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);
                }

                int currentTryCount = Int32.Parse(fakeval);

                return new OkObjectResult($"{{\"retrycount\":{currentTryCount - 1}}}");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.ToString());
                return new OkObjectResult($"{{\"retrycount\":\"undefined\"}}");
            }
        }


        public IActionResult TimeoutTest()
        {
            Thread.Sleep(10000);

            return new OkObjectResult($"{{\"TimedOut\":\"false\"}}");
        }


        public async Task<IActionResult> HttpErrorTest()
        {
            try
            {
                var fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);

                if (fakeval == null || fakeval == "" || !Int32.TryParse(fakeval, out int j))
                {
                    await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, initialTryCount.ToString());
                    fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);
                }

                int currentTryCount = Int32.Parse(fakeval);
				
                currentTryCount++;

                // Add the try count in the state store, for the next time the page is requested.
                await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, (currentTryCount).ToString());

                if (currentTryCount <= httpMaxRetries)
                {
                    Console.WriteLine($"HttpErrorTest - try # {currentTryCount}");
                    return StatusCode(503);
                }

                return new OkObjectResult($"{{\"retrycount\":{currentTryCount - 1}}}");

            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.ToString());
                return new OkObjectResult($"{{\"retrycount\":\"undefined\"}}");
            }
        }

        public async Task<IActionResult> ResponseHeaderTest()
        {
            try
            {
                var fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);

                if (fakeval == null || fakeval == "" || !Int32.TryParse(fakeval, out int j))
                {
                    await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, initialTryCount.ToString());
                    fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);
                }

                int currentTryCount = Int32.Parse(fakeval);
				
                currentTryCount++;

                // Add the try count in the state store, for the next time the page is requested.
                await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, (currentTryCount).ToString());

				if (currentTryCount <= httpMaxRetries)
                {
                    Console.WriteLine($"ResponseHeaderTest - try # {currentTryCount}");
                    Response.Headers.Add("food", "home-fries");
                }

                return new OkObjectResult($"{{\"retrycount\":{currentTryCount - 1}}}");

            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.ToString());
                return new OkObjectResult($"{{\"retrycount\":\"undefined\"}}");
            }
        }

        public async Task<IActionResult> TripTheCircuitBreaker()
        {
            try
            {
                var fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);

                if (fakeval == null || fakeval == "" || !Int32.TryParse(fakeval, out int j))
                {
                    await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, initialTryCount.ToString());
                    fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);
                }

                int currentTryCount = Int32.Parse(fakeval);
				
				currentTryCount++;
				
				await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, (currentTryCount).ToString());

				Console.WriteLine($"TripTheCircuitBreaker - try # {currentTryCount}");
				
				return StatusCode(503);
			}
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.ToString());
				return new OkObjectResult($"{{\"retrycount\":\"undefined\"}}");
            }
        }


        public async Task<IActionResult> ResetRetryCount()
        {
            try
            {
                await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, initialTryCount.ToString());
                var fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);
                int currentTryCount = Int32.Parse(fakeval);

                return new OkObjectResult($"{{\"retrycount\":{currentTryCount - 1}}}"); ;

            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.ToString());
                return new OkObjectResult($"{{\"retrycount\":\"undefined\"}}");
            }
        }
    }
}
