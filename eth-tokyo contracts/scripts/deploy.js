// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");
const abi = require("../artifacts/contracts/OneInchV5Connector.sol/OneInchV5Connector.json").abi;

const deployGoerli = async () => {
  const OneInchV5Connector = await hre.ethers.getContractFactory("OneInchV5Connector");
  const oneInchV5Connector = await OneInchV5Connector.deploy(
    "0x1111111254EEB25477B68fb85Ed929f73A960582",
  )

  await oneInchV5Connector.deployed();

  console.log(
    `Deployed to ${oneInchV5Connector.address}`
  );

  const contract = new ethers.Contract(oneInchV5Connector.address, abi, ethers.getDefaultProvider("mainnet"));
  // console.log(contract);

  const tx = await contract._swapOneInchV5(
    "0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83",
    "0x7f7440C5098462f833E123B44B8A03E1d9785BAb",
    "1000000000000000000",
    "1000000000000000000",
    "0x"
  )

  // await hre.run("verify:verify", {
  //   address: oneInchV5Connector.address,
  //   constructorArguments: [
  //     "0x1111111254EEB25477B68fb85Ed929f73A960582",
  //   ],
  // });
}




async function main() {
  deployGoerli();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});



















//TODO  /// @dev Connext contracts GNOSIS.
// IConnext public immutable connext =
//     IConnext(0x5bB83e95f63217CDa6aE3D181BA580Ef377D2109);

// /// @dev Superfluid contracts.
// ISuperfluid public immutable host =
//     ISuperfluid(0x2dFe937cD98Ab92e59cF3139138f18c823a4efE7);
// IConstantFlowAgreementV1 public immutable cfa =
//     IConstantFlowAgreementV1(0xEbdA4ceF883A7B12c4E669Ebc58927FBa8447C7D);
// ISuperToken public immutable superToken =
//     ISuperToken(0x1234756ccf0660E866305289267211823Ae86eEc);
// IERC20 public erc20Token =
//     IERC20(0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83);

// TODO  /// @dev Connext contracts POLYGON.
// IConnext public immutable connext =
//     IConnext(0x11984dc4465481512eb5b777E44061C158CF2259);

// /// @dev Superfluid contracts.
// ISuperfluid public immutable host =
//     ISuperfluid(0x3E14dC1b13c488a8d5D310918780c983bD5982E7);
// IConstantFlowAgreementV1 public immutable cfa =
//     IConstantFlowAgreementV1(0x6EeE6060f715257b970700bc2656De21dEdF074C);
// ISuperToken public immutable superToken =
//     ISuperToken(0xCAa7349CEA390F89641fe306D93591f87595dc1F);
// IERC20 public erc20Token =
//     IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

// TODO /// @dev Connext contracts MUMBAI.
// IConnext public immutable connext =
//     IConnext(0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a);

// /// @dev Superfluid contracts.
// ISuperfluid public immutable host =
//     ISuperfluid(0xEB796bdb90fFA0f28255275e16936D25d3418603);
// IConstantFlowAgreementV1 public immutable cfa =
//     IConstantFlowAgreementV1(0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873);
// ISuperToken public immutable superToken =
//     ISuperToken(0xFB5fbd3B9c471c1109A3e0AD67BfD00eE007f70A);
// IERC20 public erc20Token =
//     IERC20(0xeDb95D8037f769B72AAab41deeC92903A98C9E16);

// TODO /// @dev Connext contracts GOERLI.
// IConnext public immutable connext =
//     IConnext(0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649);

// /// @dev Superfluid contracts.
// ISuperfluid public immutable host =
//     ISuperfluid(0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9);
// IConstantFlowAgreementV1 public immutable cfa =
//     IConstantFlowAgreementV1(0xEd6BcbF6907D4feEEe8a8875543249bEa9D308E8);
// ISuperToken public immutable superToken =
//     ISuperToken(0x3427910EBBdABAD8e02823DFe05D34a65564b1a0);
// IERC20 public erc20Token =
//     IERC20(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);

/// @dev Validates callbacks.
/// @param _agreementClass MUST be CFA.
/// @param _token MUST be supported token.

///TODO  @dev Gelato OPs Contract POLYGON
// address payable _ops = payable(0x527a819db1eb0e34426297b03bae11F2f8B3A19E);

///TODO  @dev Gelato OPs Contract GNOSIS
// address payable _ops = payable(0x8aB6aDbC1fec4F18617C9B889F5cE7F28401B8dB);

///TODO  @dev Gelato OPs Contract MUMBAI
// address payable _ops = payable(0xB3f5503f93d5Ef84b06993a1975B9D21B962892F);

// TODO /// @dev Gelato OPs Contract GOERLI
// address payable _ops = payable(0xc1C6805B857Bef1f412519C4A842522431aFed39);
