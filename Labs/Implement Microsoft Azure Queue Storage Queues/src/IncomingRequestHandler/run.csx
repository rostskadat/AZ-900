#r "Newtonsoft.Json"

using System;
using System.Net;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using Azure.Storage.Queues;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string name = req.Query["name"];
    var message = await new StreamReader(req.Body).ReadToEndAsync();
    var connectionString = Environment.GetEnvironmentVariable("QueueStorageAccount", EnvironmentVariableTarget.Process);
    var queueClient = new QueueClient(connectionString, "incoming-messages");
    queueClient.SendMessage(EncodeMessage(message));
    return new OkObjectResult("Message received.");

}

public static string EncodeMessage(string message)
{
    var bytes = Encoding.UTF8.GetBytes(message);
    return Convert.ToBase64String(bytes);
}