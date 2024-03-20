// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

// interface Board {
//   function makeBoard() external pure returns (uint[][] calldata); // TODO??
// }


library SetSudokuLib {
  uint constant INDEX = 9;

  struct Set2  {
    // uint8[9]  values;
    // mapping (bytes1 => bytes1) has;
    bytes[INDEX] values;
  }
  
  struct Set {
    bytes values;
  }

  error duplicateError(uint, bytes32 , bytes4);
  error duplicateError2(bytes1, bytes4);

  // function getBoard(uint[9][9] calldata board) external pure returns (uint[9][9] calldata) {
  //    return board;
  // }

  function insert(Set memory set, uint key, bytes32 action, uint cellValue) internal pure {
    assembly {
      let tmp := byte(0, mload(add(add(mload(set), 0x20), cellValue)))
      if eq(tmp, 1) {
        let mem := mload(0x40)
        mstore(mem, hex'011d9462') // duplicateError.selector
        mstore8(add(mem, 0x23),add(cellValue, 1))
        mstore(add(mem, 0x24) , action)
        mstore(add(mem, 0x44), hex'DEADBEEF')
        revert(mem, 0x64)
      }
      mstore8(add(add(mload(set), 0x20), cellValue), 1)
    }
  }

  function contains(Set memory set, uint cellValue) internal pure returns(bytes1 result) {
    // return set.values[cellValue];
    assembly {
      result := mload(add(add(mload(set), 0x20), cellValue))
    }
  }

  function reset(Set memory set) internal pure {
    assembly {
          let tmp := not(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
          let emptyBytes := 0
          tmp := and(tmp, emptyBytes)
          mstore(add(mload(set), 0x20), tmp)
          tmp := and(tmp, mload(add(mload(set), 0x20)))
          if or(tmp, 0) {
            let frame := mload(0x40)
            mstore(frame, hex"4e487b71") //Panic
            mstore(add(frame, 0x4), 1)
            revert(frame, 0x24)
          }
      }
  }
}


contract SudokuMem {
  using SetSudokuLib for SetSudokuLib.Set;

  uint8 constant INDEX = 9;

  // SetSudokuLib.Set seenList;
  event Log(string indexed message);
  error duplicateError2(bytes1, bytes4);

  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    uint cellValue;
    SetSudokuLib.Set memory seen;
    seen.values = new bytes(1);
    assembly {
      for { let r := 0 } lt(r, 9) { r := add(r, 1) } {
        for { let c := 0 } lt(c, 9) { c := add(c, 1) } {
          cellValue := calldataload(add(add(mul(0x120, r), sudokuBoard) ,mul(0x20, c)))
          // need to check!!!
          if gt(cellValue, 9) {
            let mem := mload(0x40)
            // let error := shl(0xe5, 0x461bcd)
            // Error(string), which hashes to 0x08c379a0
            mstore(mem, shl(0xe5, 0x461bcd))
            mstore(add(mem, 0x04), 0x20)
            mstore(add(mem, 0x24), 0x0f)
            mstore(add(mem, 0x44), "number too high")
            revert(mem, 0x64)
          }

          if gt(cellValue, 0) {  //rows
            cellValue := sub(cellValue, 1)
            let seenList := add(mload(seen), 0x20)
            let mask := hex'FF'
            let result := and(mload(add(seenList, cellValue)), mask)
            if eq(result, hex'01') {
              let mem := mload(0x40)
              mstore(mem, hex'f3175e8b')//duplicateError2
              mstore8(add(mem, 0x04), add(1, cellValue))
              mstore(add(mem, 0x24), hex'DEADBEEF')
              revert(mem, 0x44)
            }
            mstore8(add(seenList, cellValue), 1)
          }

      // cols
          cellValue := calldataload(add( add(mul(0x20, r), sudokuBoard), mul(0x120, c)))
          // need to check!!!
          if gt(cellValue, 9) {
            let mem := mload(0x40)
            // Error(string), which hashes to 0x08c379a0
            mstore(mem, shl(0xe5, 0x461bcd))
            mstore(add(mem, 0x04), 0x20)
            mstore(add(mem, 0x24), 0x0f)
            mstore(add(mem, 0x44), "number too high")
            revert(mem, 0x64)
          }
          if gt(cellValue, 0) {  //rows
            cellValue := sub(cellValue, 1)
          
            let seenList := add(mload(seen), 0x20)
            let mask := hex'ff'
            let result := and(mload(add(add(seenList, cellValue), 0xa)), mask)
            if eq(result, hex'01') {
              let mem := mload(0x40)
              mstore(mem, hex'f3175e8b')//duplicateError2
              mstore8(add(mem, 0x04), add(cellValue, 1))
              mstore(add(mem, 0x24), hex'FDFDFDFD')
              revert(mem, 0x44)
          }
            mstore8(add(add(seenList, cellValue), 0xa), 1)
          }

      //blocks
          let i := add(mul(div(r, 3), 3) , div(c, 3))
          let j := add(mul(mod(r,3), 3), mod(c, 3))
          cellValue := calldataload(add(add(mul(0x120, i), sudokuBoard), mul(0x20, j)))
          if gt(cellValue, 0) {  //rows
            cellValue := sub(cellValue, 1)
            // need to check!!!
            if gt(cellValue, 9) {
              let mem := mload(0x40)
              mstore(mem, shl(0xe5, 0x461bcd))
              mstore(add(mem, 0x04), 0x20)
              mstore(add(mem, 0x24), 0x0f) 
              mstore(add(mem, 0x44), "number too high") 
              revert(mem, 0x64)
            }
            
            let seenList := add(mload(seen), 0x20)
            let mask := 0xFF00000000000000000000000000000000000000000000000000000000000000
            let tmp := add(add(seenList, cellValue), 0x14)
            let result := and(mload(tmp), mask)
            if eq(result, hex'01') {
              let mem := mload(0x40)
              mstore(mem, hex'f3175e8b')//duplicateError2
              mstore8(add(mem, 0x04), add(cellValue, 1)) 
              mstore(add(mem, 0x24), hex'BEBEBEBE')
              revert(mem, 0x44)
            }
            mstore8(tmp, 1)
          }
          
        }          
          mstore(add(mload(seen), 0x20), 0)
          let mask := not(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
          mask := and(mask, mload(add(mload(seen), 0x20)))
          if or(mask, 0) {
            let frame := mload(0x40)
            mstore(frame, hex"4e487b71") //Panic
            mstore(add(frame, 0x4), 1)
            revert(frame, 0x24)
          }
        }
    }

    return 2; // true
  }

  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;

    assembly {
      mstore(seenListMem, 0)
      let next := seenListMem
      seenListMem := 0
      mstore(0x40, next)

      for { let r := 0 } lt(r, 9) { r := add(r, 3) } {
        for {let c := 0 } lt(c, 9) { c := add(c, 3)} {
          let seenList := mload(seenListMem)
          for { let i:= r} lt(i, add(r,3)) { i:= add(i,1)} {
            for { let j := c } lt(j, add(c,3)) { j := add(j, 1) } {
              let cellValue := calldataload(add(add(mul(0x120, i), sudokuBoard), mul(0x20, j)))
              // need to check!!!
              if gt(cellValue, 9) {
                let mem := mload(0x40)
                // Error(string), which hashes to 0x08c379a0
                mstore(mem, shl(0xe5, 0x461bcd))
                mstore(add(mem, 0x04), 0x20)
                mstore(add(mem, 0x24), 0x0f)
                mstore(add(mem, 0x44), "number too high")
                revert(mem, 0x64)
              }

              if gt(cellValue, 0) {  //rows
                cellValue := sub(cellValue, 1)
                let mask := hex'ff'
                let tmp := add(seenList, cellValue)
                let result := and(mload(tmp), mask)
                //  error duplicateError2(bytes1, bytes4); // f3175e8b
                if eq(result, hex'01') {
                    let mem := mload(0x40)
                    mstore(mem, hex'f3175e8b')//duplicateError2
                    mstore8(add(mem, 0x04), add(cellValue, 1))
                    mstore(add(mem, 0x24), hex'BEBEBEBE')
                    revert(mem, 0x44)
                }

                mstore8(tmp, 1)
              }
            }
          }
          mstore(seenList, 0)

          let mask := not(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
          mask := and(mask, mload(seenList))
          if or(mask, 0) {
            let frame := mload(0x40)
            mstore(frame, hex"4e487b71") //Panic
            mstore(add(frame, 0x4), 1)
            revert(frame, 0x24)
          }
        }
      }
    }

    // emit Log("blocks");
    return 2;
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;
    seenListMem.values = new bytes(9);
  
    for (uint row = 0; row < 9; row++) {
      insertListInner(seenListMem, sudokuBoard, "rows", row);
    }
    // emit Log("row");
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;
    seenListMem.values = new bytes(9);
    
    for (uint i = 0; i < 9; i++) {
        insertListInner(seenListMem, sudokuBoard, "cols", i);
    }
    return 2;
  }

  function insertListInner(SetSudokuLib.Set memory seenListMem, uint[9][9] calldata board, bytes32 note, uint position) private pure {
    uint cellValue;

    for (uint j = 0; j< 9; j++) {
      assembly {
        if eq(note, "rows") {
          cellValue := calldataload(add(add(mul(0x120, position), board), mul(0x20, j)))
        }
        if eq(note, "cols") {
          cellValue := calldataload(add(add(mul(0x20, position),board), mul(0x120, j))) // col
        }
        if gt(cellValue, 9) {
          let mem := mload(0x40)
          // Error(string), which hashes to 0x08c379a0
          mstore(mem, shl(0xe5, 0x461bcd))
          mstore(add(mem, 0x04), 0x20)
          mstore(add(mem, 0x24), 0x0f)
          mstore(add(mem, 0x44), "number too high")
          revert(mem, 0x64)
        }
      }
      if(cellValue == 0) { // empty cell
        continue;
      }
      seenListMem.insert(j, note, cellValue - 1);
    }

    assertTest(seenListMem);
  }

  function assertTest(SetSudokuLib.Set memory seen) private pure {
    seen.reset();
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }
}
