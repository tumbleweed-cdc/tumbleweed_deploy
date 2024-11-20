const validateIpAddress = (ip) => {
  const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;
  const splitIps = ip.split('.');

  return ipRegex.test(ip) && splitIps.every((num) => parseInt(num) >= 0 && parseInt(num) <= 255);
}

export const validateListOfIps = (ips) => {
  return ips.every(ip => validateIpAddress(ip));
}