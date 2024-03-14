import { FirehoseClient, PutRecordCommand } from "@aws-sdk/client-firehose"; // ES Modules import

const handler = async (event) => {
  // Create Kinesis Data Firehose instance
  const firehose = new FirehoseClient({ region: "us-east-1" });

  // Check if request body exists
  if (!event.body) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Request body is missing" }),
    };
  }

  // Extract request body from the event
  const requestBody = JSON.parse(event.body);

  try {
    // Send request body data to Firehose stream
    let streamName;

    if (event.body.user_id !== null && event.body.user_id !== undefined) {
      streamName = "users-firehose-delivery-stream";
    } else {
      streamName = "events-firehose-delivery-stream";
    }

    const params = {
      DeliveryStreamName: streamName, // Specify your Firehose delivery stream name
      Record: {
        Data: Buffer.from(JSON.stringify(requestBody)),
      },
    };

    const command = new PutRecordCommand(params);
    const response = await firehose.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify(response),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: `Error sending data to Firehose: ${error.message} `,
      }),
    };
  }
};

export { handler };
