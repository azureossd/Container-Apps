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
//using static Dapr.Client.Autogen.Grpc.v1.Dapr;

namespace Resiliency.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
		
	    DaprClient _daprClient = new DaprClientBuilder().Build();

        const string DAPR_STORE_NAME = "mystatestore";

        const string INGRESS_HTTP_CURRENT_TRIES_KEY = "INGRESS_HTTP_CURRENT_TRIES_KEY";

        const int initialTryCount = 0;

        const int httpMaxRetries = 3;

        private static HttpClient httpClient = new HttpClient();

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public async Task<IActionResult> Index()
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

                ViewBag.RetryCount = (currentTryCount - 1).ToString();
            }
            catch (Exception ex)
            {
                ViewBag.RetryCount = "There was an issue with processing the state.";
                Console.WriteLine("Exception: " + ex.ToString());
            }

            return View();
        }

        public IActionResult TimeoutTest()
        {
            Thread.Sleep(10000);

            ViewBag.TimedOut = "false";

            return View();
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
				
				ViewBag.RetryCount = (currentTryCount - 1).ToString();

                if (currentTryCount <= httpMaxRetries)
                {
                    Console.WriteLine($"HttpErrorTest - try # {currentTryCount}");
                    return StatusCode(503);
                }
            }
            catch (Exception ex)
            {
                ViewBag.RetryCount = "There was an issue with processing the state.";
                Console.WriteLine("Exception: " + ex.ToString());
            }

            return View();
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
				
				ViewBag.RetryCount = (currentTryCount - 1).ToString();
				
                if (currentTryCount <= httpMaxRetries)
                {
                    Console.WriteLine($"ResponseHeaderTest - try # {currentTryCount}");
					Response.Headers.Add("food", "home-fries");
				}

                ViewBag.RetryCount = (currentTryCount - 1).ToString();

            }
            catch (Exception ex)
            {
                ViewBag.RetryCount = "There was an issue with processing the state.";
                Console.WriteLine("Exception: " + ex.ToString());
            }

            return View();
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
				ViewBag.RetryCount = (currentTryCount - 1).ToString();

				
				return StatusCode(500);
			}
            catch (Exception ex)
            {
                ViewBag.RetryCount = "There was an issue with processing the state.";
                Console.WriteLine("Exception: " + ex.ToString());
            }
			
			return View();
        }

        public async Task<IActionResult> ResetRetryCount()
        {
            try
            {
                await _daprClient.SaveStateAsync(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY, initialTryCount.ToString());
                var fakeval = await _daprClient.GetStateAsync<string>(DAPR_STORE_NAME, INGRESS_HTTP_CURRENT_TRIES_KEY);
                int currentTryCount = Int32.Parse(fakeval);

                ViewBag.RetryCount = (currentTryCount -1).ToString();

            }
            catch (Exception ex)
            {
                ViewBag.RetryCount = "There was an issue with processing the state.";
                Console.WriteLine("Exception: " + ex.ToString());
            }
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
