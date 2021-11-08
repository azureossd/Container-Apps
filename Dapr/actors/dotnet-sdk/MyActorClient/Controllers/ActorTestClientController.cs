using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Actors;
using Dapr.Actors.Client;
using MyActor.Interfaces;
using MyActorClient.Models;

namespace MyActorClient.Controllers
{
    public class ActorTestClientController : Controller
    {
        public async Task<IActionResult> ActorTest1()
        {
            Console.WriteLine("Entering ActorTestClientController...");

            ViewBag.PropertyA = "unable to contact MyActorService :(";
            ViewBag.PropertyB = "unable to contact MyActorService :(";

            // Registered Actor Type in Actor Service
            var actorType = "MyActor";

            // An ActorId uniquely identifies an actor instance
            // If the actor matching this id does not exist, it will be created
            var actorId = new ActorId("1");

            // Create the local proxy by using the same interface that the service implements.
            //
            // You need to provide the type and id so the actor can be located. 
            var proxy = ActorProxy.Create<IMyActor>(actorId, actorType);

            // Now you can use the actor interface to call the actor's methods.
            try
            {
                Console.WriteLine($"Calling SetDataAsync on {actorType}:{actorId}...");

                var response = await proxy.SetDataAsync(new MyData()
                {
                    PropertyA = "ValueA",
                    PropertyB = "ValueB",
                });
                Console.WriteLine($"Got response: {response}");

            Console.WriteLine($"Calling GetDataAsync on {actorType}:{actorId}...");
            var savedData = await proxy.GetDataAsync();
            Console.WriteLine($"Got response:");
            Console.WriteLine($"PropertyA: {savedData.PropertyA}");
            Console.WriteLine($"PropertyB: {savedData.PropertyB}");

            ViewBag.PropertyA = savedData.PropertyA;
            ViewBag.PropertyB = savedData.PropertyB;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception when trying to call proxy.SetDataAsync:");
                Console.WriteLine(ex.ToString());
            }

            return View();
        }
    }
}
