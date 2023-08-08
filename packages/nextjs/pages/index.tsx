import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { ArrowSmallRightIcon, BugAntIcon, MagnifyingGlassIcon, SparklesIcon } from "@heroicons/react/24/outline";
import { MetaHeader } from "~~/components/MetaHeader";
import { NftCollection } from "~~/components/nft-collection/NftCollection";
import { useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

const Home: NextPage = () => {
  const { address } = useAccount();

  const { writeAsync, isLoading, isMining } = useScaffoldContractWrite({
    contractName: "ColorCityNFT",
    functionName: "mintItem",
    value: "0.05",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-2xl mb-2">UNIQUE COLOR RENDITION OF TORONTO, CANADA.</span>
            <span className="block text-4xl font-bold">COLOR CITY NFT.</span>
          </h1>

          <div className="flex justify-center items-center flex-col">
            <p className="text-lg">MINT FOR 0.05 ETH</p>
            <div
              onClick={() => writeAsync()}
              className={`btn btn-primary text-black bg-[#1AFD3F] rounded-full flex font-normal items-center uppercase text-sm  py-3 w-28 hover:bg-[#1AFD3F] hover:gap-1 transition-all duration-500 ${
                isMining ? "loading" : ""
              }`}
            >
              {!isMining && (
                <>
                  Mint <ArrowSmallRightIcon className="w-3 h-3 mt-0.5" />
                </>
              )}
            </div>
          </div>
          {/* <p className="text-center text-lg">
            Get started by editing{" "}
            <code className="italic bg-base-300 text-base font-bold">packages/nextjs/pages/index.tsx</code>
          </p>
          <p className="text-center text-lg">
            Edit your smart contract <code className="italic bg-base-300 text-base font-bold">YourContract.sol</code> in{" "}
            <code className="italic bg-base-300 text-base font-bold">packages/hardhat/contracts</code>
          </p> */}
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <NftCollection />
        </div>
      </div>
    </>
  );
};

export default Home;
