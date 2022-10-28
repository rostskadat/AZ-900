#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Linq;
using Azure.Storage.Queues;

public class QueueStatistics
{
    public string Name { get; set; }
    public int ApproximateMessagesCount { get; set; }
}

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    var queues = new[] { "incoming-messages", "outgoing-messages" };
    var queueStatistics = queues.Select(x => GetQueueStatistics(x));
    return new OkObjectResult(queueStatistics);
}

private static QueueStatistics GetQueueStatistics(string queueName)
{
    return new QueueStatistics
    {
        Name = queueName,
        ApproximateMessagesCount = GetApproximateMessagesCountForQueue(queueName),
    };
}

private static int GetApproximateMessagesCountForQueue(string queueName)
{
    var connectionString = Environment.GetEnvironmentVariable("QueueStorageAccount", EnvironmentVariableTarget.Process);
    var queueClient = new QueueClient(connectionString, queueName);
    var queueProperties = queueClient.GetProperties().Value;
    return queueProperties.ApproximateMessagesCount;
}