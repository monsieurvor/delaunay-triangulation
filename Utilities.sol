//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library utils {

    // generates a random number between two values
    function random(uint256 input, uint256 min, uint256 max) internal pure returns (uint256) {
        uint256 randRange = max - min;
        return max - (uint256(keccak256(abi.encodePacked(input))) % randRange) - 1;
    }

    // converts an unsigned integer to a string
    function uintToStr(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // converts token ID to its respective date
    function tokenToDate(uint256 tokenId) internal pure returns (string memory date) {
        if (tokenId <= 31) {
            return string.concat(uintToStr(tokenId), ' January 2023');
        }
        if (tokenId > 31 && tokenId <= 59) {
            return string.concat(uintToStr(tokenId - 31), ' February 2023');
        }
        if (tokenId > 59 && tokenId <= 90) {
            return string.concat(uintToStr(tokenId - 59), ' March 2023');
        }
        if (tokenId > 90 && tokenId <= 120) {
            return string.concat(uintToStr(tokenId - 90), ' April 2023');
        }
        if (tokenId > 120 && tokenId <= 151) {
            return string.concat(uintToStr(tokenId - 120), ' May 2023');
        }
        if (tokenId > 151 && tokenId <= 181) {
            return string.concat(uintToStr(tokenId - 151), ' June 2023');
        }
        if (tokenId > 181 && tokenId <= 212) {
            return string.concat(uintToStr(tokenId - 181), ' July 2023');
        }
        if (tokenId > 212 && tokenId <= 243) {
            return string.concat(uintToStr(tokenId - 212), ' August 2023');
        }
        if (tokenId > 243 && tokenId <= 274) {
            return string.concat(uintToStr(tokenId - 243), ' September 2023');
        }
        if (tokenId > 274 && tokenId <= 304) {
            return string.concat(uintToStr(tokenId - 274), ' October 2023');
        }
        if (tokenId > 304 && tokenId <= 335) {
            return string.concat(uintToStr(tokenId - 304), ' November 2023');
        }
        if (tokenId > 335 && tokenId <= 365) {
            return string.concat(uintToStr(tokenId - 335),' December 2023');
        }
    }
}