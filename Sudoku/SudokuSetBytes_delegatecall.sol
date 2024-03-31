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

//DONE key for hash  
function insert(Set storage set, uint key, bytes32 action, bytes1 cellValue) external {
    if (contains(set, key, cellValue) == hex'01') revert duplicateError(cellValue, action, hex'DEADBEEF');
    
    assembly {
      mstore(0, key)
      mstore(0x20, set.slot)
 
      let shifted := mod( cellValue, 0xff )
      let position := shl( mul( shifted, 8 ), shifted)
      let result :=  and( mul( exp( 0x100, shifted ) , 0xff ) , position )
      let mask := not(mul(exp(0x100, shifted), 0xff))

      result := or(and(mask, sload(keccak256(0, 0x40))), result)
      sstore(keccak256(0, 0x40), result)
    }
  }

  function contains(Set storage set, uint key, bytes1 cellValue) public view returns(bytes1 result) {
    assembly {
      mstore(0, key)
      mstore(0x20, set.slot)

      result := sload(keccak256(0, 0x40))
      let val := mod(cellValue, 0xff)
      let position := shl(mul(val, 8), val)
      position := and(position, mul(exp(0x100, val), 0xff))

      if and(result, position) {
        result := hex"01"
      }
    }
  }

   function reset(Set storage set, uint key) public {
    assembly {
      mstore(0, key)
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
    } // end asm
  }

  function setSlot(Set storage set, bytes32 _slot) external pure {
    assembly {
      set.slot := _slot
    }
  }
}

contract Sudoku {
  using SetSudokuLib for SetSudokuLib.Set;

  uint constant INDEX = 9;

  SetSudokuLib.Set seenList;
  event Log(string indexed message);
  address public destLib;

  constructor(address _setLib) {
    destLib = _setLib;
  }

  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    uint cellValue;

    SetSudokuLib.Set2 memory rowList;
    SetSudokuLib.Set2 memory colList;
    SetSudokuLib.Set2 memory blockList;

    assembly {
      let current := mload(rowList) // 0xa0

      for {let r := 0 } lt(r, 9) { r := add(r, 1)} {
        for {let c := 0 } lt(c, 9) { c := add(c, 1)} {
          cellValue := calldataload(add(add(mul(0x120, r), sudokuBoard), mul(0x20, c)))

          if gt(cellValue, 9){
            let mem := mload(0x40)
            mstore(mem, hex"08c379a0")
            mstore(add(mem, 0x4), 0x20)
            mstore(add(mem, 0x24), 0xf)
            mstore(add(mem, 0x44), "number too high")
            revert(mem, 0x64)
          }

          if gt(cellValue, 0) {
            // we dont really need this but just for completeness ..
            if gt(mul(cellValue, 0x20), mul(INDEX, 0x20)) {
              mstore(0, hex"4e487b71")
              mstore(0x4, 0x32)
              revert(0, 0x24)
            }

            let result := mload(add(mul(0x20, sub(cellValue, 1)), mload(rowList)))
            let shifted := shl(mul(31,8),cellValue)

            switch iszero(sub(result, shifted))
            case 1 {
              let mem := mload(0x40)
              mstore(mem, hex"f3175e8b") // duplicateError2(bytes1,bytes4)
              mstore(add(mem, 0x4),shifted)
              mstore(add(mem, 0x24), hex"deadbeef") // 0x64656164
              revert(mem, 0x44)
            }
            default {
              mstore(add(mload(rowList), mul(0x20, sub(cellValue, 1))), shifted)
            }
  
          } // endrow

          cellValue := calldataload(add(add(mul(0x120, c), sudokuBoard), mul(0x20, r))) // cols

          if gt(cellValue, 9){
            let mem := mload(0x40)
            mstore(mem, hex"08c379a0")
            mstore(add(mem, 0x4), 0x20)
            mstore(add(mem, 0x24), 0xf)
            mstore(add(mem, 0x44), "number too high")
            revert(mem, 0x64)
          }

          if gt(cellValue, 0) {
            // we dont really need this but just for completeness ..
           // index out of bounds
            if gt(mul(cellValue, 0x20), mul(INDEX, 0x20)) {
              mstore(0, hex"4e487b71")
              mstore(0x4, 0x32)
              revert(0, 0x24)
            }
            let result := mload(add(mul(0x20, sub(cellValue, 1)), mload(colList)))
            let shifted := shl(mul(31,8),cellValue) // 0x05

            switch iszero(sub(result, shifted))
            case 1 {
              let mem := mload(0x40)
              mstore(mem, hex"f3175e8b") // duplicateError2(bytes1,bytes4)
              mstore(add(mem, 0x4),shifted)
              mstore(add(mem, 0x24), hex"FDFDFDFD")
              revert(mem, 0x44)
            }
            default {
              mstore(add(mload(colList), mul(0x20, sub(cellValue, 1))), shifted)
            }
          } // endcol
          
          let i := add(mul(div(r, 3), 3) , div(c, 3))
          let j := add(mul(mod(r,3), 3), mod(c, 3))

          cellValue := calldataload(add(add(mul(0x120, i), sudokuBoard), mul(0x20, j))) // blocks

          if gt(cellValue, 9){
            let mem := mload(0x40)
            mstore(mem, hex"08c379a0")
            mstore(add(mem, 0x4), 0x20)
            mstore(add(mem, 0x24), 0xf)
            mstore(add(mem, 0x44), "number too high")
            revert(mem, 0x64)
          }

          if gt(cellValue, 0) {
            // we dont really need this but just for completeness ..
            if gt(mul(cellValue, 0x20), mul(INDEX, 0x20)) {
              mstore(0, hex"4e487b71")
              mstore(0x4, 0x32)
              revert(0, 0x24)
            }
            let result := mload(add(mul(0x20, sub(cellValue, 1)), mload(blockList)))
            let shifted := shl(mul(31,8),cellValue)

            // check duplicates
            switch iszero(sub(result, shifted))
            case 1 {
              let mem := mload(0x40)
              mstore(mem, hex"f3175e8b") // duplicateError2(bytes1,bytes4)
              mstore(add(mem, 0x4),shifted)
              mstore(add(mem, 0x24), hex"bebebebe") // 0x64656164
              revert(mem, 0x44)
            }
            default {
              mstore(add(mload(blockList), mul(0x20, sub(cellValue, 1))), shifted)
            }
          }


        } // endfor
        // delete and reuse memory
        for { let i := 0 } lt(i, 9) {i := add(i, 1)} {
          let mem := add(mload(rowList), mul(0x20, i))
          switch iszero(mload(mem))
          case 0 {
            mstore(mem, 0)
            let val := mload(mem)
            val := and(mul(exp(0x100, 0x1f), 0xff), val)
            if gt(val, 0) {
              let frame := mload(0x40)
              mstore(frame, hex"4e487b71") //Panic
              mstore(add(frame, 0x4), 1)
              revert(frame, 0x24)
            }
          }
          default {    }

          mem := add(mload(colList), mul(0x20, i))

          switch iszero(mload(mem))
          case 0 {
            mstore(mem, 0)
            let val := mload(mem)
            val := and(mul(exp(0x100, 0x1f), 0xff), val)
            if gt(val, 0) {
              let frame := mload(0x40)
              mstore(frame, hex"4e487b71") //Panic
              mstore(add(frame, 0x4), 1)
              revert(frame, 0x24)
            }
          }

          mem := add(mload(blockList), mul(0x20, i))

          switch iszero(mload(mem))
          case 0 {
            mstore(mem, 0)
            let val := mload(mem)
            val := and(mul(exp(0x100, 0x1f), 0xff), val)
            if gt(val, 0) {
              let frame := mload(0x40)
              mstore(frame, hex"4e487b71") //Panic
              mstore(add(frame, 0x4), 1)
              revert(frame, 0x24)
            }
          }
        }


      } // endfor
    } // endasm


    return 2; // true
  }


  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) public {
    uint blockNumber = 0;
    bytes4 selector = SetSudokuLib.insert.selector;
    bytes4 resetselector = SetSudokuLib.reset.selector;

    assembly {
      if iszero(extcodesize(sload(destLib.slot))) {
        let mem := mload(0x40)
        mstore(mem, hex"08c379a0")
        mstore(add(mem, 0x4), 0x20)
        mstore(add(mem, 0x24), 0xd)
        mstore(add(mem, 0x44), "error library")
        revert(mem, 0x64)
        // revert(0,0) // error library
      }
      for {let r := 0} lt(r , 9) {  r:= add(r, 3)} {
        for {let c := 0} lt(c , 9) { c := add(c, 3)} {

          let _i := add(r, 3)
          let _j := add(c, 3)

          for { let i := r} lt(i , _i) { i := add(i, 1)} {
            for { let j := c} lt(j , _j) { j := add(j, 1)} {

              let cell := shl(248, calldataload(add(add(mul(0x120, i), sudokuBoard), mul(0x20, j))))

              if gt(cell, hex"09") {
                let mem := mload(0x40)
                mstore(mem, hex"08c379a0") // Error string
                mstore(add(mem, 0x4), 0x20) // offset
                mstore(add(mem, 0x24), 0xf)
                mstore(add(mem, 0x44), "number too high")
                revert(mem, 0x64)
              }

              if gt(cell, 0){
                let encoded := mload(0x40)
                mstore(encoded, selector)
                mstore(add(encoded, 0x4), seenList.slot)
                mstore(add(encoded, 0x24), blockNumber)
                mstore(add(encoded, 0x44), "blocks")
                mstore(add(encoded, 0x64), cell)

                let result := delegatecall(gas(), sload(destLib.slot), encoded, 0x84, 0, 0)

                if iszero(result) {
                  if gt(returndatasize(), 0) {
                    let pos := mload(0x40)
                    returndatacopy(pos, 0, returndatasize()) // bubbled stuff
                    revert(pos, returndatasize())
                  }
                  revert(0,0)
                }
              }
            }
          }
          // reset call
          let mem := mload(0x40)
          mstore(mem, resetselector)
          mstore(add(mem, 0x4), seenList.slot)
          mstore(add(mem, 0x24), blockNumber)

          let result := delegatecall(gas(), sload(destLib.slot), mem, 0x44, 0, 0)

          if iszero(result) {
            if gt(returndatasize(), 0) {
              let pos := mload(0x40)
              returndatacopy(pos, 0, returndatasize()) // bubbled stuff
              revert(pos, returndatasize())
            }
            revert(0,0)
          }
          // blockNumber := add(blockNumber, 1)
        }
      }
    } // endasm

    assertTest(blockNumber);
    // emit Log("blocks");
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) public returns (uint) {
    // address _libAdd = address(SetSudokuLib);
    bytes4 selector = SetSudokuLib.insert.selector;
    uint row;

   for (row = 0; row < 9; row++) {
    insertListInner(sudokuBoard, "rows", row, selector);
    }
    assertTest(row);
    // emit Log("row");
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) public returns (uint)  {
    // address _libAdd = address(SetSudokuLib);
    bytes4 selector = SetSudokuLib.insert.selector;    
    uint i;

    for (i = 0; i < 9; i++) {
      insertListInner(sudokuBoard, "cols", i, selector);
    }
      assertTest(i);
      // emit Log("Cols");
      return 2;
  }

  function insertListInner(uint[9][9] calldata board, bytes32 note, uint position, bytes4 selector) private {
    bytes1 cellValue;

    assembly {
      if iszero(extcodesize(sload(destLib.slot))) {
        let mem := mload(0x40)
        mstore(mem, hex"08c379a0")
        mstore(add(mem, 0x4), 0x20)
        mstore(add(mem, 0x24), 0xd)
        mstore(add(mem, 0x44), "error library")
        revert(mem, 0x64)
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
          mstore(add(frame, 0x24), position)
          mstore(add(frame, 0x44), note)
          mstore(add(frame, 0x64), cellValue)
        
          let result := delegatecall(gas(), sload(destLib.slot), frame, 0x84, 0, 0) 

          if iszero(result) {
            if gt(returndatasize(), 0) {
              let pos := mload(0x40)
              returndatacopy(pos, 0, returndatasize()) // bubbled stuff
              revert(pos, returndatasize())
            }
            revert(0,0)
          }
        }
      } // end for
    } // end asm

    assertTest(position);
  }

  function assertTest(uint key) private {
    seenList.reset(key);
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }

}
