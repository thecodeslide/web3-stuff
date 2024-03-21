// SPDX-License-Identifier: NON-AI AGPL-3.0-only
// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

library SetSudokuLib {
  struct Set  {
    uint8[9]  values;
    mapping (bytes1 => bytes1) has;
  }

  struct Set2 {
    bytes1[9]  values;
  }

  error duplicateError(bytes1, bytes32 , bytes4);
  error duplicateError2(bytes1, bytes4);

//TODO key for hash  
function insert(Set storage set, uint key, bytes32 action, bytes1 cellValue) external {
    if (contains(set, cellValue) == hex'01') revert duplicateError(cellValue, action, hex'DEADBEEF');
    assembly {
      mstore(0, cellValue) 
      mstore(0x20, set.slot)
      sstore(keccak256(0, 0x40), cellValue)
    }
  }

  function contains(Set storage set, bytes1 cellValue) public view returns(bytes1 result) {
    assembly {
      mstore(0, cellValue)
      mstore(0x20, set.slot)
      if sload(keccak256(0, 0x40)) {
        result := hex"01"
      }
    }
  }

   function reset(Set storage set) internal {
    assembly {
      for { let i := 1 } lt(i, 10) { i := add(i, 1) } {
        mstore8(0, i)
        mstore(0x20, set.slot)
        let hash:= keccak256(0, 0x40)
        
        if sload(hash) {
          sstore(hash, 0)
          let _hash := sload(hash)
          let mask := not(mul(0xff, exp(0x100, 0x1f)))
          _hash := and(mask, _hash)
          sstore(hash, _hash)
          if or(_hash, sload(hash)) {
            let frame := mload(0x40)
            mstore(frame, hex"4e487b71") //Panic
            mstore(add(frame, 0x4), 1)
            revert(frame, 0x24)
          }
        }
      } 
    } // end asm
  }
}

contract Sudoku {
  using SetSudokuLib for SetSudokuLib.Set;

  uint constant INDEX = 9;

  SetSudokuLib.Set seenList;
  event Log(string indexed message);

  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    uint cellValue;

    SetSudokuLib.Set2 memory rowList;
    SetSudokuLib.Set2 memory colList;
    SetSudokuLib.Set2 memory blockList;
   
    for (uint r = 0; r < 9; r++) {
        for(uint c = 0; c < 9; c++) { // 
            cellValue = sudokuBoard[r][c];
            require(bytes1(uint8(cellValue)) < hex'0A', "number too high");

            if(cellValue != 0) {
                cellValue = sudokuBoard[r][c] -1; // index
                if(rowList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'DEADBEEF') ;
                }
                rowList.values[cellValue] = hex'01';
            }

            cellValue = sudokuBoard[c][r]; // index
            if(cellValue != 0) {
                cellValue -= 1;
                if(colList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)),  hex'FDFDFDFD') ;
                }
                colList.values[cellValue] = hex'01';
            }

            cellValue = sudokuBoard[3* (r / 3) + c/3][3*(r%3)+(c%3)];
            if(cellValue != 0) {
                cellValue -= 1;
                if(blockList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'BEBEBEBE') ;
                }
                blockList.values[cellValue] = hex'01';
            }
        }

        delete rowList.values;
        delete colList.values;
        delete blockList.values;
    }

    return 2; // true
  }


  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) public {
    uint blockNumber = 0;
    uint count = 0; // for dev. can be removed

    for (uint rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint colBlock = 0; colBlock < 9; colBlock += 3) {
        for (uint miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            bytes1 cellValue = bytes1(uint8(sudokuBoard[miniRow][miniCol]));
            seenList.insert(count++, "blocks", (cellValue));

          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;
        assertTest();
      }
    }
    assertTest();
    // emit Log("blocks");
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) public returns (uint) { // transfer seenlist
    address _libAdd = address(SetSudokuLib);
    bytes4 selector = SetSudokuLib.insert.selector;

   for (uint row = 0; row < 9; row++) {
    insertListInner(sudokuBoard, "rows", row, selector, _libAdd);
    }
    assertTest();
    // emit Log("row");
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) public returns (uint)  {
    address _libAdd = address(SetSudokuLib);
    bytes4 selector = SetSudokuLib.insert.selector;    

    for (uint i = 0; i < 9; i++) {
      insertListInner(sudokuBoard, "cols", i, selector, _libAdd);
    }
      assertTest();
      // emit Log("Cols");
      return 2;
  }

  function insertListInner(uint[9][9] calldata board, bytes32 note, uint position, bytes4 selector, address _libAdd) private {
    bytes1 cellValue;

    assembly {
      if iszero(extcodesize(_libAdd)) {
        revert(0,0)
      }

      for { let j := 0 } lt(j, 9) {j := add(j, 1)} {
        switch note 
        case "rows" {
          cellValue := shl(248, calldataload(add(add(mul(0x120, position), board) ,mul(0x20, j))))
        }
        default { // cols
          cellValue := shl(248, calldataload(add(add(mul(0x20, position), board) ,mul(0x120, j))))
        }

        if gt(cellValue, hex"09") {
          let mem := mload(0x40)
          // Error(string)
          mstore(mem, shl(0xe5, 0x461bcd))
          mstore(add(mem, 0x04), 0x20) 
          mstore(add(mem, 0x24), 0x0f)
          mstore(add(mem, 0x44), "number too high")
          revert(mem, 0x64)
        }

        if gt(cellValue, 0) {
          let frame := mload(0x40)
          mstore(frame, selector)
          mstore(add(frame, 0x4), seenList.slot)
          mstore(add(frame, 0x24), j)
          mstore(add(frame, 0x44), note)
          mstore(add(frame, 0x64), cellValue)
        
          let result := delegatecall(gas(), _libAdd, frame, 0x84, 0, 0) 

          if iszero(result) {
            if gt(returndatasize(), 0) {
              let pos := mload(0x40)
              returndatacopy(pos, 0, returndatasize()) // bubble errors??
              revert(pos, returndatasize())
            }
            revert(0,0)
          }
        }
      } // end for
    } // end asm

    assertTest();
  }

  function assertTest() private {
    seenList.reset();
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }

}



