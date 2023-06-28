async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);

    const Marketplace = await ethers.deployContract("NFTMarketplace");

    await Marketplace.waitForDeployment();
  
    console.log("Marketplace address:", await Marketplace.getAddress());
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });