//
//  Ops.swift
//  CoinKit
//
//  Created by Elliott Minns on 16/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

enum OPCodes: String {
  case OP_FALSE
  case OP_0
  case OP_PUSHDATA1
  case OP_PUSHDATA2
  case OP_PUSHDATA4
  case OP_1NEGATE
  case OP_RESERVED
  case OP_TRUE
  case OP_1
  case OP_2
  case OP_3
  case OP_4
  case OP_5
  case OP_6
  case OP_7
  case OP_8
  case OP_9
  case OP_10
  case OP_11
  case OP_12
  case OP_13
  case OP_14
  case OP_15
  case OP_16
  case OP_NOP
  case OP_VER
  case OP_IF
  case OP_NOTIF
  case OP_VERIF
  case OP_VERNOTIF
  case OP_ELSE
  case OP_ENDIF
  case OP_VERIFY
  case OP_RETURN
  case OP_TOALTSTACK
  case OP_FROMALTSTACK
  case OP_2DROP
  case OP_2DUP
  case OP_3DUP
  case OP_2OVER
  case OP_2ROT
  case OP_2SWAP
  case OP_IFDUP
  case OP_DEPTH
  case OP_DROP
  case OP_DUP
  case OP_NIP
  case OP_OVER
  case OP_PICK
  case OP_ROLL
  case OP_ROT
  case OP_SWAP
  case OP_TUCK
  case OP_CAT
  case OP_SUBSTR
  case OP_LEFT
  case OP_RIGHT
  case OP_SIZE
  case OP_INVERT
  case OP_AND
  case OP_OR
  case OP_XOR
  case OP_EQUAL
  case OP_EQUALVERIFY
  case OP_RESERVED1
  case OP_RESERVED2
  case OP_1ADD
  case OP_1SUB
  case OP_2MUL
  case OP_2DIV
  case OP_NEGATE
  case OP_ABS
  case OP_NOT
  case OP_0NOTEQUAL
  case OP_ADD
  case OP_SUB
  case OP_MUL
  case OP_DIV
  case OP_MOD
  case OP_LSHIFT
  case OP_RSHIFT
  case OP_BOOLAND
  case OP_BOOLOR
  case OP_NUMEQUAL
  case OP_NUMEQUALVERIFY
  case OP_NUMNOTEQUAL
  case OP_LESSTHAN
  case OP_GREATERTHAN
  case OP_LESSTHANOREQUAL
  case OP_GREATERTHANOREQUAL
  case OP_MIN
  case OP_MAX
  case OP_WITHIN
  case OP_RIPEMD160
  case OP_SHA1
  case OP_SHA256
  case OP_HASH160
  case OP_HASH256
  case OP_CODESEPARATOR
  case OP_CHECKSIG
  case OP_CHECKSIGVERIFY
  case OP_CHECKMULTISIG
  case OP_CHECKMULTISIGVERIFY
  case OP_NOP1
  case OP_NOP2
  case OP_CHECKLOCKTIMEVERIFY
  case OP_NOP3
  case OP_CHECKSEQUENCEVERIFY
  case OP_NOP4
  case OP_NOP5
  case OP_NOP6
  case OP_NOP7
  case OP_NOP8
  case OP_NOP9
  case OP_NOP10
  case OP_PUBKEYHASH
  case OP_PUBKEY
  case OP_INVALIDOPCODE
}

extension OPCodes {
  var value: UInt8 {
    switch self {
      case .OP_FALSE: return 0
      case .OP_0: return 0
      case .OP_PUSHDATA1: return 76
      case .OP_PUSHDATA2: return 77
      case .OP_PUSHDATA4: return 78
      case .OP_1NEGATE: return 79
      case .OP_RESERVED: return 80
      case .OP_TRUE: return 81
      case .OP_1: return 81
      case .OP_2: return 82
      case .OP_3: return 83
      case .OP_4: return 84
      case .OP_5: return 85
      case .OP_6: return 86
      case .OP_7: return 87
      case .OP_8: return 88
      case .OP_9: return 89
      case .OP_10: return 90
      case .OP_11: return 91
      case .OP_12: return 92
      case .OP_13: return 93
      case .OP_14: return 94
      case .OP_15: return 95
      case .OP_16: return 96
      case .OP_NOP: return 97
      case .OP_VER: return 98
      case .OP_IF: return 99
      case .OP_NOTIF: return 100
      case .OP_VERIF: return 101
      case .OP_VERNOTIF: return 102
      case .OP_ELSE: return 103
      case .OP_ENDIF: return 104
      case .OP_VERIFY: return 105
      case .OP_RETURN: return 106
      case .OP_TOALTSTACK: return 107
      case .OP_FROMALTSTACK: return 108
      case .OP_2DROP: return 109
      case .OP_2DUP: return 110
      case .OP_3DUP: return 111
      case .OP_2OVER: return 112
      case .OP_2ROT: return 113
      case .OP_2SWAP: return 114
      case .OP_IFDUP: return 115
      case .OP_DEPTH: return 116
      case .OP_DROP: return 117
      case .OP_DUP: return 118
      case .OP_NIP: return 119
      case .OP_OVER: return 120
      case .OP_PICK: return 121
      case .OP_ROLL: return 122
      case .OP_ROT: return 123
      case .OP_SWAP: return 124
      case .OP_TUCK: return 125
      case .OP_CAT: return 126
      case .OP_SUBSTR: return 127
      case .OP_LEFT: return 128
      case .OP_RIGHT: return 129
      case .OP_SIZE: return 130
      case .OP_INVERT: return 131
      case .OP_AND: return 132
      case .OP_OR: return 133
      case .OP_XOR: return 134
      case .OP_EQUAL: return 135
      case .OP_EQUALVERIFY: return 136
      case .OP_RESERVED1: return 137
      case .OP_RESERVED2: return 138
      case .OP_1ADD: return 139
      case .OP_1SUB: return 140
      case .OP_2MUL: return 141
      case .OP_2DIV: return 142
      case .OP_NEGATE: return 143
      case .OP_ABS: return 144
      case .OP_NOT: return 145
      case .OP_0NOTEQUAL: return 146
      case .OP_ADD: return 147
      case .OP_SUB: return 148
      case .OP_MUL: return 149
      case .OP_DIV: return 150
      case .OP_MOD: return 151
      case .OP_LSHIFT: return 152
      case .OP_RSHIFT: return 153
      case .OP_BOOLAND: return 154
      case .OP_BOOLOR: return 155
      case .OP_NUMEQUAL: return 156
      case .OP_NUMEQUALVERIFY: return 157
      case .OP_NUMNOTEQUAL: return 158
      case .OP_LESSTHAN: return 159
      case .OP_GREATERTHAN: return 160
      case .OP_LESSTHANOREQUAL: return 161
      case .OP_GREATERTHANOREQUAL: return 162
      case .OP_MIN: return 163
      case .OP_MAX: return 164
      case .OP_WITHIN: return 165
      case .OP_RIPEMD160: return 166
      case .OP_SHA1: return 167
      case .OP_SHA256: return 168
      case .OP_HASH160: return 169
      case .OP_HASH256: return 170
      case .OP_CODESEPARATOR: return 171
      case .OP_CHECKSIG: return 172
      case .OP_CHECKSIGVERIFY: return 173
      case .OP_CHECKMULTISIG: return 174
      case .OP_CHECKMULTISIGVERIFY: return 175
      case .OP_NOP1: return 176
      case .OP_NOP2: return 177
      case .OP_CHECKLOCKTIMEVERIFY: return 177
      case .OP_NOP3: return 178
      case .OP_CHECKSEQUENCEVERIFY: return 178
      case .OP_NOP4: return 179
      case .OP_NOP5: return 180
      case .OP_NOP6: return 181
      case .OP_NOP7: return 182
      case .OP_NOP8: return 183
      case .OP_NOP9: return 184
      case .OP_NOP10: return 185
      case .OP_PUBKEYHASH: return 253
      case .OP_PUBKEY: return 254
      case .OP_INVALIDOPCODE: return 255
    }
  }
}
