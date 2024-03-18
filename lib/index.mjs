import { FirehoseClient, PutRecordCommand } from "@aws-sdk/client-firehose";
import { v4 as uuid } from "uuid";

const getTimeStamp = () => {
  const now = new Date().toISOString();
  return now.replace("T", "").replace("Z", "");
};

const processEvent = (event) => {
  if (!event.event_id || !event.event_name || !event.user_id) {
    return new Error(
      "An 'event_name', and 'user_id' must be provided must be provided",
    );
  }

  return {
    event_id: uuid(),
    event_name: event.event_name,
    user_id: event.user_id || "default_user",
    event_attributes: event.event_attributes || null,
    event_created: getTimeStamp(),
  };
};

const processUser = (user) => {
  if (!user.user_id) {
    return new Error("A 'user_id' must be provided");
  }

  return {
    user_id: user.user_id,
    user_attributes: user.user_attributes || null,
    user_created: getTimeStamp(),
  };
};

const handler = async (event) => {
  const firehose = new FirehoseClient({ region: "us-east-1" });

  if (!event.body) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Request body is missing" }),
    };
  }

  try {
    const requestBody = JSON.parse(event.body);
    const usersStreamName = "users-firehose-delivery-stream";
    const eventsStreamName = "events-firehose-delivery-stream";

    let streamName;
    let data;

    if (event.path.endsWith("/events")) {
      streamName = eventsStreamName;
      data = processEvent(requestBody);
    } else {
      streamName = usersStreamName;
      data = processUser(requestBody);
    }

    if (data instanceof Error) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: data.message }),
      };
    }

    const params = {
      DeliveryStreamName: streamName,
      Record: {
        Data: Buffer.from(JSON.stringify(data)),
      },
    };

    const command = new PutRecordCommand(params);
    const response = await firehose.send(command);

    return {
      statusCode: 200,
      body: `Sent to stream ${streamName}. Response info: ${JSON.stringify(response)}`,
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
