import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

export const generateMerkleRoot = (addresses: string[]) => {
  try {
    const whitelistLeafNodes = addresses.map((addr: string) => keccak256(addr?.toLowerCase()));
    const whitelistMerkleTree = new MerkleTree(whitelistLeafNodes, keccak256, {
      sortPairs: true,
    });
    return {
      merkleTree: whitelistMerkleTree,
      root: whitelistMerkleTree.getHexRoot(),
    };
  } catch (e) {
    console.log(e);
  }
  return { merkleTree: null, root: null };
};

export const generateMerkleProof = (
  addresses: string[],
  whitelistAddresses: string[]
) => {
  try {
    const { merkleTree, root } = generateMerkleRoot(whitelistAddresses);
    console.log('root', root)
    if (merkleTree) {
      return addresses.map((e: string) => merkleTree.getHexProof(keccak256(e?.toLowerCase())));
    }
  } catch (e) {
    console.log(e);
  }
  return null;
};

(async() => {

    const whitelistAddresses = ["0x744b65d2909fe2ec7e556e02252009bf0265e4e4","0x99a64210cfc0c1aed571b25bca654e593827b149","0x9a6dbcecd740cd57f24aedcf766c7bb33b5afd70","0x3b7e3424b96b33aad1c5184d2af74515451af334","0x9de37512045342b197c40787473557a47c087205","0x6d325219cf971547459790c92ec53d416a163edb","0x55bf3fa10c733633c039adf84d1e248d425abde4","0xed42186b431fc68b7bb49a31be4c982a95b2c965","0x9fc3bb53b57e85d65ce1f21b6cabc0ecb5b0bb0d","0x94f527e3de7b4cc32373529c0289717c17db17de","0xb8208d1b9aad7e6404c7ec8a9039f3215673ee3e","0xc2cd27b6c639ad431b9534394bd78932f7eb176d","0xddaa9ef89c1b8c944c1ca1cc93a783a1c4d3e235","0xb8a7c30a2a34117f79b5f0a804b7327b5e2898e7","0xc7fd5e560ce2795308150d295704b324e8495396","0x192ae5441d992f5351f4da1033beac0d60ea2f4f","0x1ae6a4d3078b951438d1aa64de6c1e4e033913d6","0x5cf40d58e6f0bf2c673d4bba11f2eac0e9e9788d","0x8a636442bf236f915818bf3942c889ddfd612852","0x0b224903afc6acf4fdc17f6f71dbbb3093b238ec","0x35c4d7858597ded39326f27d60f2a2de84cad503","0x90d62fe3b7b04182bd32e523622135585df2547a","0x9ff8f84b89eadddf555b29934a9c63454404b167","0x7b00cc606f8513b92abb663467d47430a7f75527","0xbd728c1290c884f145dba723ec770b28e38a000b","0x74a7c70637570e2fa93a37276bad9fdc8f6787dd"];
    const mintAddresses = ["0xED42186B431FC68b7bB49a31Be4c982A95B2c965"];

    // SEAPORT GOERLI : 0x00000000006c3852cbEf3e08E8dF289169EdE581
    console.log(JSON.stringify(generateMerkleProof(mintAddresses, whitelistAddresses)))
    console.log(JSON.stringify(mintAddresses))
})()
