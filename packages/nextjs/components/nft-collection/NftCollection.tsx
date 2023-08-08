import { useEffect, useState } from "react";
import { Abi } from "abitype";
import { BigNumber } from "ethers";
import { createPublicClient, getContract, http } from "viem";
import { hardhat } from "viem/chains";
import { useAccount, usePublicClient, useWalletClient } from "wagmi";
import { GetWalletClientResult } from "wagmi/actions";
import contracts from "~~/generated/deployedContracts";
// import { hardhat } from "wagmi/chains";
import { useDeployedContractInfo, useScaffoldContract } from "~~/hooks/scaffold-eth";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";

export interface Collectible {
  id: number;
  uri: string;
  owner: string;
  description: string;
  external_url: string;
  image: string;
  name: string;
  attributes: [
    {
      trait_type: string;
      value: number;
    },
  ];
}

export const NftCollection = () => {
  const client = usePublicClient({ chainId: hardhat.id });

  const { address: connectedAddress } = useAccount();
  const { data: walletClient } = useWalletClient();

  const [allCollectiblesLoading, setAllCollectiblesLoading] = useState(false);
  const [myAllCollectibles, setMyAllCollectibles] = useState<Collectible[]>([]);

  // 1. Create contract instance
  const publicClient = createPublicClient({
    chain: hardhat,
    transport: http(),
  });

  const nftContract = getContract({
    address: contracts[31337][0].contracts["ColorCityNFT"].address,
    abi: contracts[31337][0].contracts["ColorCityNFT"].abi,
    publicClient,
  });

  // keep track of a variable from the contract in the local React state:
  const { data: myTotalBalance } = useScaffoldContractRead({
    contractName: "ColorCityNFT",
    functionName: "balanceOf",
    args: [connectedAddress],
    watch: true,
  });

  console.log("🤗 balance:", myTotalBalance && Number(myTotalBalance));
  console.log("🤗 address:", connectedAddress && connectedAddress);

  useEffect(() => {
    const updateMyCollectibles = async (): Promise<void> => {
      if (myTotalBalance === undefined || nftContract === null || connectedAddress === undefined) {
        return;
      }

      setAllCollectiblesLoading(true);

      const collectibleUpdate: Collectible[] = [];
      const totalBalance = parseInt(myTotalBalance.toString());

      for (let tokenIndex = 0; tokenIndex < totalBalance; tokenIndex++) {
        try {
          console.log("Getting token index", BigInt(tokenIndex.toString()));

          const tokenId = await nftContract.read.tokenOfOwnerByIndex([connectedAddress, BigInt(tokenIndex.toString())]);

          console.log("tokenId", tokenId);

          const tokenURI = await nftContract.read.tokenURI([tokenId]);

          const jsonManifestString = atob(tokenURI!.substring(29));

          console.log("jsonManifestString", jsonManifestString);

          /*
                const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");
                console.log("ipfsHash", ipfsHash);
      
                const jsonManifestBuffer = await getFromIPFS(ipfsHash);
      
              */

          try {
            const jsonManifest = JSON.parse(jsonManifestString);

            collectibleUpdate.push({ id: tokenId, uri: tokenURI, owner: connectedAddress, ...jsonManifest });
          } catch (e) {
            console.log(e);
          }
        } catch (e) {
          notification.error("Error fetching all collectibles");
          console.log(e);
          setAllCollectiblesLoading(false);
        }
      }

      console.log(collectibleUpdate);

      setMyAllCollectibles(collectibleUpdate.reverse());

      setAllCollectiblesLoading(false);
    };

    updateMyCollectibles();
  }, [connectedAddress, myTotalBalance]);

  return (
    <>
      {myAllCollectibles.length === 0 ? (
        <div className="flex justify-center items-center mt-10">
          <div className="text-2xl text-primary-content">No NFTs found</div>
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 p-4 gap-x-2 gap-y-2">
          {myAllCollectibles.map((item, index) => (
            <div key={index} className="rounded-md border border-gray-700 ">
              <div className="mx-auto">
                <img src={item.image} className=" w-full rounded-md  transition-all duration-500" />
              </div>

              <div className="p-2">
                <h5 className="uppercase font-body">{item.name}</h5>
                <p className="text-xs  m-0">{item.description}</p>
                <div className="flex justify-between gap-x-2 m-0">
                  <div className="">
                    <p className="text-xs  m-0">Token Id :{item.id.toString()}</p>{" "}
                    {/* <p className="text-lg font-body m-0">item</p>{" "} */}
                  </div>
                  {/* <div className="text-black border border-primary  py-2 px-4 bg-[#1AFD3F] rounded-full flex justify-center items-center uppercase text-xs cursor-pointer font-body  self-center ">
                    Transfer
                  </div> */}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </>
  );
};
