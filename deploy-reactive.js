const { ethers } = require('ethers');
const fs = require('fs');

async function deployReactive() {
    console.log('=== DEPLOYING SUBSCRIPTION REACTIVE CONTRACT ===\n');
    
    // Configuration
    const PRIVATE_KEY = '0xdfe9a1d1c29b40417ee15201f33240236c1750f4ce60fe32ba809a673ab24f99';
    const REACTIVE_RPC = 'https://lasna-rpc.rnk.dev/';
    const TARGET_CHAIN_ID = 11155111; // Sepolia
    const SUBSCRIPTION_MANAGER = '0x82b069578ae3dA9ea740D24934334208b83E530E'; // NEW deployed address
    const SUBSCRIPTION_NFT = '0x404cb817FA393D3689D1405DB0B76a20eDE72d43'; // NEW deployed address
    
    // Connect to Reactive Network
    const provider = new ethers.JsonRpcProvider(REACTIVE_RPC);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    
    console.log('Deployer:', wallet.address);
    console.log('Network: Reactive Testnet');
    console.log('Target Chain ID:', TARGET_CHAIN_ID);
    console.log('Subscription Manager:', SUBSCRIPTION_MANAGER);
    console.log('Subscription NFT:', SUBSCRIPTION_NFT);
    
    // Check REACT balance
    const balance = await provider.getBalance(wallet.address);
    console.log('\nREACT Balance:', ethers.formatEther(balance), 'REACT');
    
    if (balance < ethers.parseEther('0.01')) {
        console.log('❌ Insufficient REACT balance. Need at least 0.01 REACT');
        return;
    }
    
    // Read compiled contract
    console.log('\nReading contract bytecode...');
    const contractPath = './out/SubscriptionReactive.sol/SubscriptionReactive.json';
    const contractJson = JSON.parse(fs.readFileSync(contractPath, 'utf8'));
    const bytecode = contractJson.bytecode.object;
    const abi = contractJson.abi;
    
    // Deploy contract
    console.log('\nDeploying SubscriptionReactive...');
    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    
    try {
        // Deploy without constructor args (AbstractReactive handles initialization)
        const contract = await factory.deploy();
        
        console.log('Transaction hash:', contract.deploymentTransaction().hash);
        console.log('Waiting for deployment...');
        
        await contract.waitForDeployment();
        const address = await contract.getAddress();
        
        console.log('✅ SubscriptionReactive deployed at:', address);
        
        // Send initial REACT deposit for operations
        console.log('\nSending initial REACT deposit...');
        const depositTx = await wallet.sendTransaction({
            to: address,
            value: ethers.parseEther('0.01')
        });
        await depositTx.wait();
        console.log('✅ Deposited 0.01 REACT');
        
        // Initialize the contract
        console.log('\nInitializing contract...');
        const tx1 = await contract.initialize(
            SUBSCRIPTION_MANAGER,
            SUBSCRIPTION_NFT,
            TARGET_CHAIN_ID
        );
        await tx1.wait();
        console.log('✅ Contract initialized');
        
        // Subscribe to payment events
        console.log('\nSubscribing to payment events...');
        const tx2 = await contract.subscribeToPaymentEvents(
            TARGET_CHAIN_ID,
            SUBSCRIPTION_MANAGER
        );
        await tx2.wait();
        console.log('✅ Subscribed to payment events');
        
        // Subscribe to CRON (hourly checks)
        console.log('\nSubscribing to CRON...');
        const tx3 = await contract.subscribeToCron(3600);
        await tx3.wait();
        console.log('✅ Subscribed to hourly CRON events');
        
        // Save deployment info
        console.log('\n=== DEPLOYMENT SUMMARY ===');
        console.log('SubscriptionReactive:', address);
        console.log('Target Chain:', TARGET_CHAIN_ID);
        console.log('Monitoring:', SUBSCRIPTION_MANAGER);
        console.log('NFT Contract:', SUBSCRIPTION_NFT);
        
        const deploymentInfo = {
            network: 'reactive-testnet',
            reactive: address,
            targetChainId: TARGET_CHAIN_ID,
            subscriptionManager: SUBSCRIPTION_MANAGER,
            subscriptionNFT: SUBSCRIPTION_NFT,
            deployedAt: new Date().toISOString()
        };
        
        fs.writeFileSync(
            './deployments/reactive-deployment.json',
            JSON.stringify(deploymentInfo, null, 2)
        );
        console.log('\nDeployment info saved to deployments/reactive-deployment.json');
        
        console.log('\n⚠️  NEXT STEPS:');
        console.log('1. Update SubscriptionNFT on Sepolia with Reactive address:');
        console.log(`   cast send ${SUBSCRIPTION_NFT} \\`);
        console.log(`     "setReactiveContract(address)" ${address} \\`);
        console.log('     --rpc-url https://sepolia.gateway.tenderly.co \\');
        console.log('     --private-key <YOUR_KEY>\n');
        
        return address;
        
    } catch (error) {
        console.error('❌ Deployment failed:', error.message);
        if (error.data) {
            console.error('Error data:', error.data);
        }
    }
}

deployReactive().catch(console.error);