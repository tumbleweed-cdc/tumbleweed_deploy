exports.handler = async (event) => {
  const token = event.authorizationToken;

  // Replace this with your actual validation logic
  if (token === "your_specific_iam_user_token") {
      return generatePolicy('user', 'Allow', event.methodArn);
  } else {
      return generatePolicy('user', 'Deny', event.methodArn);
  }
};

const generatePolicy = (principalId, effect, resource) => {
  const authResponse = {
      principalId,
      policyDocument: {
          Version: '2012-10-17',
          Statement: [{
              Action: 'execute-api:Invoke',
              Effect: effect,
              Resource: resource,
          }],
      },
  };
  return authResponse;
};