// SPDX-License-Identifier: NON-AI AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

library SetSudokuLib {
  uint constant INDEX = 9;

  struct Set {
    bytes1[9]  values;
  }

  error duplicateError(bytes1, bytes32 , bytes4);
  error duplicateError2(bytes1, bytes4);

  function insert(Set storage set, uint key, bytes32 action, bytes1 cellValue) internal {
    if (contains(set, cellValue) == hex'01') {
      assembly {
        let error := mload(0x40)
        mstore(error, hex"011d9462")
        mstore(add(error, 0x4) , cellValue)
        mstore(add(error, 0x24), action)
        mstore(add(error, 0x44), hex"DEADBEEF")
        revert(error, 0x64)
      }
    } 
    set.values[uint(uint8(cellValue))] = hex'01';
  }

  function contains(Set storage set, bytes1 cellValue) internal view returns(bytes1 result) {
    assembly {
      if and( sload(set.slot) , shl(mul(shr(248, cellValue), 8), 1)) {
        result := hex"01"
      }
    }
  }

   function reset(Set storage set) internal {
    assembly {
      sstore(set.slot, not(not(0)))

      if and(sload(set.slot), 1) {
        let mem := mload(0x40)
        mstore(mem, hex"4e487b71")
        mstore(add(mem, 0x4), 1)
        revert(mem, 0x24)
      }
    }
    }
}

contract Sudoku {
  using SetSudokuLib for SetSudokuLib.Set;
  
  uint constant INDEX = 9;
  
  SetSudokuLib.Set seenList;
  event Log(string indexed message);

  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) external returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    assembly {
      for { let r := 0} lt(r, 9) {r := add(r,1)} {
        for { let c := 0} lt(c, 9) {c := add(c,1)} {
          let cellValue := calldataload(add(add(mul(0x120, r), sudokuBoard) , mul(0x20, c))) // rows
          if and(gt(cellValue, 0), lt(cellValue, 10)) {
            cellValue := sub(cellValue, 1)
            let val := sload(seenList.slot)
            if and(shl(mul(cellValue, 8), 0xff) , val) {
              let mem := mload(0x40)
              mstore(mem, hex"f3175e8b")
              mstore(add(mem, 0x4), shl(mul(8, 31), add(cellValue,1)))
              mstore(add(mem, 0x24) , hex"deadbeef")
              revert(mem, 0x44)
            }
            sstore(seenList.slot, or(val, shl(mul(cellValue, 8), 1)))
          }

          // cols
          cellValue := calldataload(add(add(mul(0x120, c), sudokuBoard) , mul(0x20, r))) 
          if and(gt(cellValue, 0), lt(cellValue, 10)) {
            cellValue := add(cellValue, 0x9)
            let val := sload(seenList.slot)

            if and(shl(mul(cellValue, 8), 0xff) , val) { 
              let mem := mload(0x40)
              mstore(mem, hex"f3175e8b")
              mstore(add(mem, 0x4), shl(mul(8, 31), sub(cellValue, 0x9)))
              mstore(add(mem, 0x24) , hex"fdfdfdfd")
              revert(mem, 0x44)
            }
            sstore(seenList.slot, or(val, shl(mul(cellValue, 8), 1))) 
          }

          // block
          let i := add(mul(3, div(r, 3)) , div(c, 3))
          let j := add(mul(mod(r , 3), 3), mod(c, 3))
          cellValue := calldataload(add(add(mul(0x120, i), sudokuBoard) , mul(0x20, j))) 
          if and(gt(cellValue, 0), lt(cellValue, 10)) {
            cellValue := add(cellValue, 0x13)
            // cellValue := add(sub(cellValue, 1), 0x14)
            let val := sload(seenList.slot)

            if and(shl(mul(cellValue, 8), 0xff) , val) {
              let mem := mload(0x40)
              mstore(mem, hex"f3175e8b")
              mstore(add(mem, 0x4), shl(mul(8, 31), sub(cellValue,0x13)))
              mstore(add(mem, 0x24) , hex"bebebebe")
              revert(mem, 0x44)
            }
            sstore(seenList.slot, or(val, shl(mul(cellValue, 8), 1)))
          }
          
          // if gt(cellValue, 9) {
          //   let mem := mload(0x40)
          //   mstore(mem, hex"08c379a0")
          //   mstore(add(mem, 0x4), 0x20)
          //   mstore(add(mem, 0x24), 0xf)
          //   mstore(add(mem, 0x44), "number too high")
          //   revert(mem, 0x64)
          // }
        } 
        // clear slot
        sstore(seenList.slot, not(not(0)))
        if and(sload(seenList.slot), 1) {
          let mem := mload(0x40)
          mstore(mem, hex"4e487b71") //panic
          mstore(add(mem, 0x4), 1)
          revert(mem, 0x24)
        }
      }
    } // endasm

    return 2; // true
  }

  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) external {
    bytes1 cellValue;

    assembly {
      for {let rowBlock := 0 } lt(rowBlock , 9) { rowBlock := add(rowBlock, 3) } {
        for { let colBlock := 0 } lt(colBlock , 9) { colBlock := add(colBlock, 3) } {
          let r := add(rowBlock , 3)
          let c := add(colBlock, 3)
          for { let miniRow := rowBlock } lt(miniRow, r) { miniRow := add(miniRow, 1) } {
            for { let miniCol := colBlock } lt(miniCol, c) { miniCol := add(miniCol, 1) } {

              cellValue := calldataload(add(add(mul(miniRow, 0x120), sudokuBoard), mul(miniCol, 0x20)))

              if and(gt(cellValue, 0), lt(cellValue, 10)) {
                let val := sload(seenList.slot)
                if and(shl(mul(cellValue, 8), 0xff) , val) {
                  let mem := mload(0x40)
                  mstore(mem, hex"f3175e8b") // duplicate error2
                  mstore(add(mem, 0x4), shl(mul(8, 31), cellValue))
                  mstore(add(mem, 0x24) , hex"bebebebe")
                  revert(mem, 0x44)
                }
                
                sstore(seenList.slot, or(val, shl(mul(cellValue, 8), 1)))  
              }
            }
          }
          sstore(seenList.slot, not(not(0)))
          if and(sload(seenList.slot), 1) {
            let mem := mload(0x40)
            mstore(mem, hex"4e487b71") //panic
            mstore(add(mem, 0x4), 1)
            revert(mem, 0x24)
          }
        }
      }
      let logger := mload(0x40)
      mstore(logger, hex"626c6f636b73")
      log2(logger,0,  0xcf34ef537ac33ee1ac626ca1587a0a7e8e51561e5514f8cb36afa1c5102b3bab, keccak256(logger, 6))
    } // endasm
    // emit Log("blocks");
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) external returns (uint) {
    for (uint row = 0; row < 9; row++) {
      insertListInner(sudokuBoard, "rows", row);
    }
    assembly {
      let logger := mload(0x40)
      mstore(logger, hex"726f77")
      log2(logger, 0, 0xcf34ef537ac33ee1ac626ca1587a0a7e8e51561e5514f8cb36afa1c5102b3bab, keccak256(logger, 3))
    }
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) external returns (uint) {
    for (uint col = 0; col < 9; col++) {
        insertListInner(sudokuBoard, "cols", col);
    }
      assembly {
        let logger := mload(0x40)
        mstore(logger, hex"436f6c73")
        log2(logger,0, 0xcf34ef537ac33ee1ac626ca1587a0a7e8e51561e5514f8cb36afa1c5102b3bab, keccak256(logger, 4))
      }
      return 2;
  }

  function insertListInner(uint[9][9] calldata board, bytes32 note, uint position) private {
    uint cellValue;

    for (uint j = 0; j< 9; j++) {
      assembly {
        switch note
        case "rows" {
          cellValue :=  calldataload(add(add(mul(position, 0x120), board), mul(0x20,  j)))
        }
        default {
          cellValue :=  calldataload(add(add(mul(position, 0x20), board), mul(0x120,  j)))
        }
    
        if gt(cellValue, 9) {
          let mem := mload(0x40)
          mstore(mem, hex"08c379a0")
          mstore(add(mem, 0x4), 0x20)
          mstore(add(mem, 0x24), 0xf)
          mstore(add(mem, 0x44), "number too high")
          revert(mem, 0x64)
        }
      }

      if(cellValue == 0) {
        continue;
      }

      seenList.insert(j, note, bytes1(uint8(cellValue- 1)));
    }
    
    seenList.reset();
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }
}
