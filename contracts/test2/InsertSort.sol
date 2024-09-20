// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract InsertSort {
    function insertSort(uint[] memory nums) public pure returns (uint[] memory) {
        for (uint i = 1; i < nums.length; i++) {
            uint key = nums[i];
            uint j = i;
            while (j > 0 && key < nums[j - 1]) {
                nums[j] = nums[j - 1];
                j--;
            }
            nums[j] = key;
        }
        return nums;
    }
}