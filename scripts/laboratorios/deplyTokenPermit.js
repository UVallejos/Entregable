var { ethers } = require("hardhat");

async function main() {

  var contratoNft = await ethers.deployContract("UlisesVallejosPermit");
  var contratoAddress = await contratoNft.getAddress();
  console.log(`Address Contrato es ${contratoAddress}`);

  // Esperar una cantidad N de confirmaciones
  var res = await contratoNft.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: contratoAddress,
  });

  // $ npx hardhat --network mumbai run scripts/laboratorios/deplyTokenPermit.js
}

main();
