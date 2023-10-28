var { ethers } = require("hardhat");

async function main() {
  var _collectionName = "Ulises Vallejos Colection NFTs";
  var _collectionSymbol = "UAVSTKN";

  var contratoNft = await ethers.deployContract("Enumerable", [
    _collectionName,
    _collectionSymbol,
  ]);
  var contratoAddress = await contratoNft.getAddress();
  console.log(`Address Contrato es ${contratoAddress}`);

  // Esperar una cantidad N de confirmaciones
  var res = await contratoNft.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: contratoAddress,
    constructorArguments: [_collectionName, _collectionSymbol],
  });

  // $ npx hardhat --network mumbai run scripts/laboratorios/deployenum.js
}

main();
