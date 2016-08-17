//
//  TransferTransaction+Additions.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

extension TransferTransaction: Equatable { }

func == (lhs: TransferTransaction, rhs: TransferTransaction) -> Bool {
    return lhs.type == rhs.type &&
    lhs.timeStamp == rhs.timeStamp &&
    lhs.amount == rhs.amount &&
    lhs.fee == rhs.fee &&
    lhs.recipient == rhs.recipient &&
    lhs.message == rhs.message &&
    lhs.deadline == rhs.deadline &&
    lhs.signature == rhs.signature &&
    lhs.signer == rhs.signer
}
