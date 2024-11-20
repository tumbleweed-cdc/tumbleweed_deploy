import { exec } from 'child_process';
import { promisify } from 'util';
const execPromise = promisify(exec);

export const getTerraformPath = async () => {
  try {
    const { stdout } = await execPromise('which terraform');
    return stdout.trim();
  } catch (error) {
    console.error(`exec error: ${error}`);
    return;
  }
};