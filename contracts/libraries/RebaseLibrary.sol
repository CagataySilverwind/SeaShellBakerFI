// SPDX-License-Identifier: MIT
/*
 * This library was adapted from Boring Solidity Rebase Library
 * https://github.com/boringcrypto/BoringSolidity/blob/78f4817d9c0d95fe9c45cd42e307ccd22cf5f4fc/contracts/libraries/BoringRebase.sol
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 */
pragma solidity ^0.8.24;

struct Rebase {
    uint256 elastic;
    uint256 base;
}

/**
 * @title RebaseLibrary
 * @author Chef Kenji <chef.kenji@bakerfi.xyz>
 * @dev Library for handling rebase operations. This library was adapted from Boring Solidity Rebase Library
 */
library RebaseLibrary {
    /// @notice Calculates the base value in relationship to `elastic` and `total`.
    // @Silverwind it returns base(totalSupply) 0 if elastic(totalAsset) is 0 and reverse
    // @audit-ok It returns the token value responding to the new elastic (depositted asset amount) amount.
    // @note if the system does not have tokens but assets, this function assign the base (token/totalSupply) to something even it is zero.
    function toBase(Rebase memory total, uint256 elastic, bool roundUp) internal pure returns (uint256 base) {
        if (total.elastic == 0 || total.base == 0) {
            base = elastic;
        } else {
            base = (elastic * total.base) / total.elastic;
            if (roundUp && (base * total.elastic) / total.base < elastic) {
                base++;
            }
        }
    }

    /// @notice Calculates the elastic value in relationship to `base` and `total`.
    //                              usd/eth           token
    // @audit-ok Silverwind it returns the amount of asset corresponding to the shares 
    // Also this returns at least 1. It does not return 0 even it needs to be!
    function toElastic(Rebase memory total, uint256 base, bool roundUp) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            // @note @todo if system does not have any asset, then it sets it 1:1 ratio to token is it right?
            // -> It actually never enters here. This function only called in one place and it checks the base value to be
            // always greater than 0 or revert.
            elastic = base;
        } else {
            // @todo does any muldiv error here?
            elastic = (base * total.elastic) / total.base;
            if (roundUp && (elastic * total.base) / total.elastic < base) {
                elastic++;
            }
        }
    }
}
// Example
// total supply = 100 
// total asset = 10
// base = 20

//elastic = 20* 10 / 100 = 2
//roundUp = true && 2 * 100 / 10 < 20 
