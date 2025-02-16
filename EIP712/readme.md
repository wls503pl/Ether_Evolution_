# EIP712

EIP191 signature standard (personal sign), which can sign a message. However, it is too simple. When the signature data is complex,
the user can only see a hexadecimal string (the hash of the data) and cannot verify whether the signature content is consistent with expectations.
<br><br>
![EIP191Signature](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/EIP191Signature.png)
<br><br>

EIP712 typed data signature is a more advanced and secure signature method. When a Dapp that supports EIP712 requests a signature, the wallet will display the original data of the signed message, and the user can sign after verifying that the data meets expectations.
<br><br>
![](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/EIP712Signature.png)<br><br>

## How to use EIP712

The application of EIP712 generally includes two parts: off-chain signature (front-end or script) and on-chain verification (contract). Below we use a simple example EIP712Storage to introduce the use of EIP712.
The EIP712Storage contract has a state variable number, which needs to verify the EIP712 signature before it can be changed.

## Off-chain signature

1. The EIP712 signature must contain an EIP712Domain part, which contains the contract name, version (generally agreed to be "1"), chainId and verifyingContract (verifying the contract address of the signature).
   ```
   EIP712Domain: [
     { name: "name", type: "string" },
     { name: "version", type: "string" },
     { name: "chainId", type: "uint256" },
     { name: "verifyingContract", type: "address" },]
   ```
   This information will be displayed when the user signs and ensure that only a specific contract on a specific chain can verify the signature. You need to pass the corresponding parameters in the script.
   ```
   const domain = {
     name: "EIP712Storage",
     version: "1",
     chainId: "1",
     verifyingContract: "0xf8e81D47203A594245E36C48e151709F0C19fBe8", };
   ```

2. You need to customize the data type of a signature according to the usage scenario, and it must match the contract. In the EIP712Storage example, we defined a Storage type, which has two members:
   **spender** of address type, which specifies the caller who can modify the variable; **number** of uint256 type, which specifies the value of the variable after modification.
   ```
   const types =
   {
     Storage: [
       {name: "spender", type: "addresss"},
       {name: "number", type: "uint256"},
     ],
   };
   ```

3. Create a message variable and pass in the typed data to be signed.
   ```
   const message = {
     spender: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
     number: "100",
   };
   ```

4. Call the ***signTypedData()*** method of the wallet object and pass in the domain, types, and message variables in the previous step for signing (ethersjs v6 is used here).
   ```
   // Get the provider
   const provider = new ethers.BrowserProvider(window.ethereum)
   // After getting the signer, call the signTypedData method to perform the eip712 signature
   const signature = await signer.signTypedData(domain, types, message);
   console.log("Signature:", signature);
   ```

## On-chain verification

Next is the **EIP712Storage** contract part, which needs to verify the signature, and if it passed, it modifies the state variable **number**. It has 5 state variables.
1. **EIP712DOMAIN_TYPEHASH**: EIP712Domain type hash, a constant.
2. **STORAGE_TYPEHASH**: Storage type hash, a constant.
3. **DOMAIN_SEPARATOR**: This is a unique value per domain (Dapp) mixed into the signature, consisting of **EIP712DOMAIN_TYPEHASH** and **EIP712Domain** (name, version, chainId, verifyingContract), initialized in ***constructor()***.
4. **number**: The state variable that stores the value in the contract can be modified by the ***permitStore()*** method.
5. **owner**: The contract owner is initialized in the ***constructor()*** and verifies the validity of the signature in the ***permitStore()*** method.

In addition, the EIP712Storage contract has 3 functions.
1. ***Constructor***: Initialize DOMAIN_SEPARATOR and owner.
2. ***retrieve()***: Read the value of number.
3. ***permitStore***: Verify the EIP712 signature and modify the value of number. First, it disassembles the signature into r, s, and v. Then it uses DOMAIN_SEPARATOR, STORAGE_TYPEHASH, the caller address, and the input _num parameter to spell out the message text digest of the signature. Finally, it uses the recover() method of ECDSA to recover the signer address. If the signature is valid, it updates the value of number.

## Deployment Recurrence

1. Deploy the **EIP712Storage** contract in Remix.
   <br><br>
   ![DeployEIP712Storage](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/DeployEIP712Storage.png)
   <br><br>

2. Run **eip712storage.html**. According to the browser's Content Security Policy, MetaMask cannot communicate with DApp through opened local files (file://           protocol). You can use the Node static file server http-server to start the local service and execute the following command in the directory containing the         **eip712storage.html** file:
   ```
   npm install -g http-server
   http-server
   ```
   ![http_server](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/http_server.png)
   <br>
   Open http://127.0.0.1:8080 in your browser to access it. Then change the Contract Address to the deployed **EIP712Storage** contract address, and then click       the Connect Metamask and Sign Permit buttons to sign. To sign, use the wallet that deployed the contract, such as the Remix test wallet:
   <br>
   ![eip712storage_html](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/eip712storage_html.png)
   <br>
   ![eip712_SignatureExample](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/eip712_SignatureExample.png)
   ```
   public_key: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
   private_key: 503f38a9c967ed597e47fe25643985f032b072db8075426a92110f82df48dfcb
   ```
   ![connectToWallet](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/connectToWallet.png)
   <br>
   ![RemixWallet1_Coinbase](https://github.com/wls503pl/Ether_Evolution_/blob/ee/EIP712/img/RemixWallet1_Coinbase.png)

3. Call the ***permitStore()*** method of the contract, enter the corresponding _num and signature, and modify the value of number.
4. Call the ***retrieve()*** method of the contract and see that the value of number has changed.
