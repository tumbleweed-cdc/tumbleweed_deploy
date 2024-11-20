import { ECSClient, DescribeServicesCommand } from "@aws-sdk/client-ecs";
import { TumColors } from "./colors.js";
import ora from 'ora';

const services = [
  "tumbleweed-app",
  "tumbleweed-user-config-db",
  "kafka-controller-1",
  "kafka-controller-2",
  "kafka-controller-3",
  "kafka-broker-1",
  "kafka-broker-2",
  "kafka-broker-3",
  "connect-debezium",
  "apicurio-registry"
];

let awsRegion;

const checkForActiveService = async (serviceName) => {
  const ecsClient = new ECSClient({ awsRegion });

  try {
    const command = new DescribeServicesCommand({
      cluster: "tumbleweed-cluster",
      services: [serviceName]
    });

    const response = await ecsClient.send(command);
    const service = response.services?.[0];

    if (service) {
      const serviceStatus = service.status;
      if (serviceStatus === "ACTIVE") {
        console.log(TumColors.green(`Service ${serviceName} is ACTIVE.`));
        return true;
      } else {
        console.log(TumColors.darkOrange(`Service ${serviceName} is not ACTIVE yet. Current status: ${serviceStatus}`));
        return false;
      }
    } else {
      console.log(TumColors.darkOrange(`Service ${serviceName} not found in cluster tumbleweed-cluster`));
      return false;
    }
  } catch (error) {
    console.log(TumColors.darkOrange(`Error checking service state: ${error.message}`));
    return false;
  }
};

export const waitForActiveServices = async (region) => {
  awsRegion = region;

  const spinner = ora(TumColors.lightYellow.bold('Checking if services are active...')).start();

  const timeout = 12000;
  const timeoutPromise = new Promise((_, reject) =>
    setTimeout(() => reject(new Error("Timeout reached, stopping the checks.")), timeout)
  );

  const serviceChecks = services.map((service) => {
    return new Promise(async (resolve) => {
      let isRunning = false;
      while (!isRunning) {
        isRunning = await checkForActiveService(service);
        if (!isRunning) {
          const delay = 3000;
          await new Promise(resolve => setTimeout(resolve, delay));
        } else {
          resolve();
        }
      }
    });
  });

  try {
    await Promise.race([Promise.all(serviceChecks), timeoutPromise]);

    spinner.succeed(TumColors.green.bold('Tumbleweed services have been deployed.'));
  } catch (error) {
    if (error.message === "Timeout reached, stopping the checks.") {
      spinner.fail(TumColors.darkOrange('A Timeout has occured. Tumblweed services may not have been deployed.'), error.message);
    } else {
      spinner.fail(TumColors.darkOrange('Error occurred while checking deployed Tumbleweed services:' ), error.message);
    }
  }
};

const checkForStableService = async (serviceName, attempts) => {
  const ecsClient = new ECSClient({ awsRegion });

  try {
    const command = new DescribeServicesCommand({
      cluster: "tumbleweed-cluster",
      services: [serviceName]
    });

    const response = await ecsClient.send(command);
    const service = response.services?.[0];

    if (service) {
      const deployment = service.deployments?.[0];
      const serviceStatus = service.status;
      const desiredCount = deployment.desiredCount;
      const runningCount = deployment.runningCount;
      const rolloutState = deployment.rolloutState;

      if (serviceStatus === "ACTIVE" && desiredCount === runningCount && rolloutState === "COMPLETED") {
        console.log(TumColors.green(`Service ${serviceName} has reached a stable state.`));
        return true;
      } else if (attempts === 1 && rolloutState !== "COMPLETED") {
        console.log(TumColors.darkOrange(`Service ${serviceName} is ${serviceStatus} but not yet stable.`));
        return false;
      } else {
        return false;
      }
    }
  } catch (error) {
    console.log(TumColors.darkOrange(`Error checking service state: ${error.message}`));
    return false;
  }
};

export const waitForStableServices = async (region) => {
  awsRegion = region;

  const spinner = ora(TumColors.lightYellow.bold('Checking the status of deployed services...')).start();

  const serviceChecks = services.map((service) => {
    return new Promise(async (resolve, reject) => {
      let isRunning = false;
      let attempts = 0;
      const maxAttempts = 70;
      
      while (!isRunning && attempts < maxAttempts) {
        attempts++;
        isRunning = await checkForStableService(service, attempts);
        
        if (!isRunning) {
          if (service === "connect-debezium" && attempts > 1) {
            console.log(TumColors.darkOrange(`Service ${service} is still not stable. This may take up to 8 minutes.`));
          } else if (attempts > 1) {
            console.log(TumColors.darkOrange(`Service ${service} is still not stable.`));
          }
          const retryTime = 8000;
          await new Promise(resolve => setTimeout(resolve, retryTime));
        } else {
          resolve();
        }
      }

      if (!isRunning) {
        reject(new Error(`Service ${service} did not stabilize within the allowed attempts.`));
      }
    });
  });

  try {
    await Promise.all(serviceChecks);
    spinner.succeed(TumColors.green.bold('Tumbleweed is now rolling!'));
  } catch (error) {
    spinner.fail(TumColors.darkOrange('Error occurred while checking deployed Tumbleweed services:'), error.message);
  }
};
