import { FirehoseClient, PutRecordCommand } from "@aws-sdk/client-firehose"; // ES Modules import

const handler = async (event) => {
  // Create Kinesis Data Firehose instance
  const firehose = new FirehoseClient({ region: "us-east-1" });

  // Extract request body from the event
  const requestBody = JSON.parse(event.body);


  // Check if request body exists
  if (!requestBody) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Request body is missing' }),
    };
  }

  try {
    // Send request body data to Firehose stream
    const params = {
      DeliveryStreamName: 'events', // Specify your Firehose delivery stream name
      Record: {
        Data: Buffer.from(JSON.stringify(requestBody)),
      }
    };


    const command = new PutRecordCommand(params);
    const response = await firehose.send(command);


    return response;
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: `Error sending data to Firehose: ${error.message} ` }),
    };
  }
};

export { handler };









