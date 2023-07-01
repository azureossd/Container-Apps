using ShowRequestHeaders.Models;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Headers;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Specialized;
using System.Diagnostics;

namespace ShowRequestHeaders.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            foreach (var header in Request.Headers)
            {
                ViewBag.Headers += "Header key: " + header.Key + "<br />";
                ViewBag.Headers += "Header value: " + header.Value + "<br />";
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