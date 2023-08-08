//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

import "./HexStrings.sol";
import "./ToColor.sol";

//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract ColorCityNFT is ERC721, Ownable {
	using Strings for uint256;
	using HexStrings for uint160;
	using ToColor for bytes3;
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	constructor() public ERC721("ColorCity", "CC") {}

	// attributes
	mapping(uint256 => bytes3) public primaryColor;
	mapping(uint256 => bytes3) public secondaryColor;

	uint256 mintDeadline = block.timestamp + 2 weeks;

	uint256 mintFee = 0.05 ether;

	function mintItem() public payable returns (uint256) {
		require(block.timestamp < mintDeadline, "DONE MINTING");

		require(msg.value == mintFee, "Eth must be equal to mint fee");

		_tokenIds.increment();

		uint256 id = _tokenIds.current();
		_mint(msg.sender, id);

		bytes32 predictableRandomprimary = keccak256(
			abi.encodePacked(
				blockhash(block.number - 1),
				msg.sender,
				address(this)
			)
		);

		bytes32 predictableRandomSecondary = keccak256(
			abi.encodePacked(block.timestamp, address(this), msg.sender)
		);

		primaryColor[id] =
			bytes2(predictableRandomprimary[0]) |
			(bytes2(predictableRandomprimary[1]) >> 8) |
			(bytes3(predictableRandomprimary[2]) >> 16);

		secondaryColor[id] =
			bytes2(predictableRandomSecondary[0]) |
			(bytes2(predictableRandomSecondary[1]) >> 8) |
			(bytes3(predictableRandomSecondary[2]) >> 16);

		return id;
	}

	function tokenURI(uint256 id) public view override returns (string memory) {
		require(_exists(id), "not exist");
		string memory name = string(
			abi.encodePacked("ColorCity#", id.toString())
		);
		string memory description = string(
			abi.encodePacked(
				"Color City NFT. Primary Color: #",
				primaryColor[id].toColor(),
				" Secondary Color: #",
				secondaryColor[id].toColor()
			)
		);

		string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name":"',
								name,
								'", "description":"',
								description,
								'", "external_url":"https://burnyboys.com/token/',
								id.toString(),
								'", "attributes": [{"trait_type": "primary_color", "value": "#',
								primaryColor[id].toColor(),
								'"},  {"trait_type": "secondary_color", "value": "#',
								secondaryColor[id].toColor(),
								'"}], "owner":"',
								(uint160(ownerOf(id))).toHexString(20),
								'", "image": "',
								"data:image/svg+xml;base64,",
								image,
								'"}'
							)
						)
					)
				)
			);
	}

	struct ColorHex {
		string primaryColorHex;
		string secondaryColorHex;
	}

	function generateSVGofTokenById(
		uint256 id
	) internal view returns (string memory) {
		string memory svg = string(
			abi.encodePacked(
				'<svg width="2480" height="3508" viewBox="0 0 2480 3508" fill="none" xmlns="http://www.w3.org/2000/svg">',
				renderTokenByIdOne(id),
				renderTokenByIdTwo(id),
				renderTokenByIdThree(id),
				renderTokenByIdFour(id),
				"</svg>"
			)
		);

		return svg;
	}

	// Visibility is `public` to enable it being called by other contracts for composition.

	function renderTokenByIdOne(
		uint256 id
	) public view returns (string memory) {
		string memory render = string(
			abi.encodePacked(
				'<rect width="2480" height="3508" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M0 3398H2480V918H0V3398Z" fill="#',
				primaryColor[id].toColor(),
				'"/>  <path d="M1455.48 1632.96C1455.48 1632.96 1495.71 1615.36 1535.99 1602.73C1567.63 1592.81 1599.3 1585.96 1611.55 1593.13C1639.37 1609.43 1421.03 1665.39 1418.47 1657.95C1415.9 1650.51 1411.96 1622.94 1411.96 1622.94L1418.17 1620.16L1437.25 1637.52L1455.48 1632.96" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1539.71 1616.67C1538.89 1620.38 1520.18 1707.17 1506.69 1711.08C1493.21 1714.99 1507.52 1623.87 1507.52 1623.87L1539.71 1616.67" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1544.32 1606.22C1544.32 1606.22 1563.81 1563.12 1555.93 1559.44C1548.04 1555.77 1513.23 1605.48 1511.14 1619.12C1509.06 1632.76 1544.32 1606.22 1544.32 1606.22Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M535.864 2133.17C535.864 2281.15 415.906 2401.1 267.933 2401.1C119.959 2401.1 0 2281.15 0 2133.17C0 1985.2 119.959 1865.24 267.933 1865.24C415.906 1865.24 535.864 1985.2 535.864 2133.17Z" fill="white"/>',
				'<path d="M864.667 2435.07C864.667 2583.05 744.709 2703 596.737 2703C448.762 2703 328.803 2583.05 328.803 2435.07C328.803 2287.09 448.762 2167.14 596.737 2167.14C744.709 2167.14 864.667 2287.09 864.667 2435.07" fill="white"/>',
				'<path d="M1296.92 2521.59C1296.92 2669.57 1176.95 2789.52 1028.98 2789.52C881.005 2789.52 761.053 2669.57 761.053 2521.59C761.053 2373.62 881.005 2253.66 1028.98 2253.66C1176.95 2253.66 1296.92 2373.62 1296.92 2521.59Z" fill="white"/>',
				'<path d="M2114.46 2260.22C2114.46 2364.78 2029.71 2449.54 1925.15 2449.54C1820.59 2449.54 1735.83 2364.78 1735.83 2260.22C1735.83 2155.66 1820.59 2070.91 1925.15 2070.91C2029.71 2070.91 2114.46 2155.66 2114.46 2260.22Z" fill="white"/>',
				'<path d="M1854.06 2328.31C1854.06 2529.41 1691.03 2692.44 1489.93 2692.44C1288.83 2692.44 1125.8 2529.41 1125.8 2328.31C1125.8 2127.2 1288.83 1964.18 1489.93 1964.18C1691.03 1964.18 1854.06 2127.2 1854.06 2328.31Z" fill="white"/>',
				'<path d="M0 1765.49V2121.67C72.8867 2095.34 124.99 2025.55 124.99 1943.58C124.99 1861.61 72.8867 1791.83 0 1765.49" fill="white"/>',
				'<path d="M2479.98 1626.85C2431.95 1606.77 2378.82 1595.53 2322.86 1595.53C2108.98 1595.53 1935.6 1758.55 1935.6 1959.65C1935.6 2160.76 2108.98 2323.79 2322.86 2323.79C2378.82 2323.79 2431.95 2312.54 2479.98 2292.46V1966.84V1626.85" fill="white"/>',
				'<path d="M2479.98 3328.56H0V1978.56L569.507 2331.95L1164.85 2492.49L1987.4 2239.2L2347.91 1942.73L2479.98 1926.52V3328.56Z" fill="white"/>',
				'<path d="M1079.5 3175.66H1273.43L1507.73 3123.11H1585.43V3175.66L1758.07 3187.81V3303.26V3398H749.764V3224.63L892.398 3208.02L1079.5 3175.66Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1187.23 2606.38L1204.61 3397.27H1514.59L1410.3 2560.03C1410.3 2560.03 1334.97 2612.18 1187.23 2606.38" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1390.02 2502.09L1398.61 3399.61L1555.96 3401.5L1549.35 2560.03C1549.35 2560.03 1523.28 2490.5 1390.02 2502.09" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M1114.51 2737.59L1100.01 3397.27H841.454L928.448 2698.93C928.448 2698.93 991.271 2742.42 1114.51 2737.59Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M945.361 2650.6V3398.01L788.62 3397.45L812.458 2698.93C812.458 2698.93 834.207 2640.93 945.361 2650.6Z" fill="#',
				primaryColor[id].toColor()
			)
		);

		return render;
	}

	function renderTokenByIdTwo(
		uint256 id
	) public view returns (string memory) {
		string memory render = string(
			abi.encodePacked(
				'"/> <path d="M2157.84 3328.56L2143.26 2505.44H2295.26V3328.56H2157.84Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M788.62 2049.63C788.62 2244.72 630.471 2402.87 435.379 2402.87C240.291 2402.87 82.1401 2244.72 82.1401 2049.63C82.1401 1854.54 240.291 1696.39 435.379 1696.39C630.471 1696.39 788.62 1854.54 788.62 2049.63Z" fill="white"/>',
				'<path d="M2219.27 2522.09V2338.86L2232.8 2522.09H2219.27Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1859.97 3328.66V2773.64L2018.23 2782V3328.66H1859.97Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1878.16 2783.89V2757.71H2004.97V2795.19L1878.16 2783.89Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1892.03 2765.41V2726.9H1988.54V2768.49L1892.03 2765.41" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1903.84 2732.55V2703.8L1978.79 2701.23V2738.2L1903.84 2732.55" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1915.64 2708.94V2677.62L1968 2680.19V2708.94H1915.64Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1939.1 2693.28L1940.29 2617.04H1946.45V2696.1L1939.1 2693.28Z" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M70.9729 3329.29L65.8442 3210.73L94.0582 3209.88C94.0582 3209.88 177.688 3072.53 381.926 3076.18C586.163 3079.83 664.576 3212.95 664.576 3212.95L693.274 3209.94L690.864 3328.31L70.9729 3329.29" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M536.126 3328.56C536.126 3328.56 441.651 2572 457.548 2440.9L424.828 2440.91C444.737 2572 372.259 3328.56 372.259 3328.56H536.126Z" fill="#',
				primaryColor[id].toColor()
			)
		);

		return render;
	}

	function renderTokenByIdThree(
		uint256 id
	) public view returns (string memory) {
		string memory render = string(
			abi.encodePacked(
				'"/> <path d="M373.953 2440.93L511.822 2444.36L511.495 2422.7L504.497 2415.94L522 2410.52L521.554 2381.43L488.192 2350.99L498.788 2342.87L497.92 2336.1L384.597 2336.15L384.766 2346.98L393.291 2353.74L362.363 2384.2L362.809 2413.3L382.79 2418.03L369.877 2424.8L373.953 2440.93" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M422.865 2345.23L422.949 1929.01L447.681 1929L460.559 2349.02L422.865 2345.23" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M414.641 2299.63L467.329 2299.6L467.548 2313.86L414.857 2313.88L414.641 2299.63" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M467.195 2167.75C467.404 2181.52 454.94 2192.7 439.349 2192.71C423.76 2192.71 410.951 2181.55 410.74 2167.78C410.529 2154 422.995 2142.82 438.584 2142.82C454.175 2142.81 466.984 2153.97 467.195 2167.75" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M427.335 1941.82L427.465 1802.63L433.38 1802.62L443.426 1954.23L427.335 1941.82" fill="#',
				primaryColor[id].toColor()
			)
		);

		return render;
	}

	function renderTokenByIdFour(
		uint256 id
	) public view returns (string memory) {
		string memory render = string(
			abi.encodePacked(
				'"/> <path d="M1735.83 3280.78H1903.84L1988.54 3209.23H2037.64L2070.9 3280.78L2219.27 3293.57L2255.1 3239.18L2244.87 3124.4H2331.86V3187.81H2421.4V3328.56L1694.81 3329.69L1735.83 3280.78" fill="#',
				secondaryColor[id].toColor(),
				'"/> <path d="M1725.56 3336.58C1725.56 3336.58 1852.69 3126.87 2056.39 3115.46C2235.06 3105.46 2378.84 3258.87 2418.35 3339.77H2400.39C2400.39 3339.77 2282.22 3127.78 2069.79 3128.61C1879.03 3129.36 1748.54 3339.77 1748.54 3339.77L1725.56 3336.58" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M1623 3343.97C1623 3343.97 1750.13 3134.26 1953.82 3122.85C2132.49 3112.85 2276.28 3266.26 2315.78 3347.16H2297.82C2297.82 3347.16 2179.64 3135.17 1967.22 3136C1776.46 3136.75 1645.98 3347.16 1645.98 3347.16L1623 3343.97" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M1520.42 3336.58C1520.42 3336.58 1647.56 3126.87 1851.25 3115.46C2029.92 3105.46 2173.71 3258.87 2213.21 3339.77H2195.26C2195.26 3339.77 2077.08 3127.78 1864.65 3128.61C1673.9 3129.36 1543.41 3339.77 1543.41 3339.77L1520.42 3336.58" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M0 3269C9.56933 3269 854.96 3289.4 854.96 3289.4V3398.56L0 3396.21V3289.4" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M2480 3269C2470.43 3269 1525.56 3289.4 1525.56 3289.4V3398.56L2480 3397.44V3289.4" fill="#',
				primaryColor[id].toColor(),
				'"/> <path d="M1216.53 3323.38L1216.53 3323.33L1216.53 3323.38Z" fill="white"/>',
				'<path d="M1216.94 3325.96H1216.95C1216.79 3325.22 1216.67 3324.5 1216.58 3323.78C1216.67 3324.5 1216.79 3325.23 1216.94 3325.96" fill="white"/>',
				'<path d="M1219.6 3333.42L1219.55 3333.32L1219.6 3333.42Z" fill="white"/>',
				'<path d="M1219.35 3332.92L1219.14 3332.51L1219.35 3332.92Z" fill="white"/>',
				'<path d="M1217.69 3328.83C1218.08 3330.07 1218.55 3331.28 1219.11 3332.42C1218.55 3331.25 1218.08 3330.05 1217.7 3328.83H1217.69" fill="white"/>',
				'<path d="M620.387 1817.04L1020.38 1729.98L1420.38 1642.93L1423.95 1657.93L662.923 1877.18L646.796 1842.99L620.387 1817.04Z" fill="url(#paint0_radial_202_2)"/>',
				"<defs>",
				'<radialGradient id="paint0_radial_202_2" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(1411.52 1655.25) rotate(165.717) scale(772.786 41085.9)">',
				'<stop stop-color="#',
				secondaryColor[id].toColor(),
				'"/> <stop offset="1" stop-color="white"/>',
				"</radialGradient>",
				"</defs>"
			)
		);

		return render;
	}

	function getBalance() public view returns (uint) {
		return address(this).balance;
	}

	function withdraw() public payable onlyOwner {
		(bool sent, ) = payable(msg.sender).call{
			value: address(this).balance
		}("");
		require(sent, "Withdraw(): revert in transferring eth to you!");
	}

	receive() external payable {}
}
