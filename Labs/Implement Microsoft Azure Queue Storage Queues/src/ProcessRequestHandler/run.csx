#r "Newtonsoft.Json"

using System;
using System.Linq;
using Newtonsoft.Json;

public class Message
{
    public string Name { get; set; }
    public string Comment { get; set; }
    public string Sentiment { get; set; }
}

public static Message Run(string myQueueItem, ILogger log)
{
    var message = JsonConvert.DeserializeObject<Message>(myQueueItem);
    message.Sentiment = PredictMessageSentiment(message.Comment);
    return message;
}

private static string PredictMessageSentiment(string messageComment)
{
    if (messageComment.Contains("complain")) {
        return "Unhappy";
    } else if (messageComment.Contains("praise")) {
        return "Happy";
    } else {
        return "Neutral";
    }
}

