// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MessagingReceipt, MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

import { IOtcMarketCore } from "./IOtcMarketCore.sol";

interface IOtcMarketCreateOffer is IOtcMarketCore {
    /**
     * @dev Parameters required to create an offer.
     */
    struct CreateOfferParams {
        bytes32 beneficiary;
        uint32 dstEid;
        bytes32 srcTokenAddress;
        bytes32 dstTokenAddress;
        uint256 srcAmountLD;
        uint64 exchangeRateSD;
    }

    /**
     * @dev Struct representing CreateOffer receipt information.
     */
    struct CreateOfferReceipt {
        bytes32 offerId;
        uint256 amountLD; // amount actually taken from the advertiser
    }

    /**
     * @dev Supplied amount is smaller than required.
     */
    error InsufficientValue(uint256 required, uint256 supplied);

    /**
     * @dev Too small amount or exchange rate in create or accept offer.
     */
    error InvalidPricing(uint256 srcAmountLD, uint64 exchangeRateSD);

    /**
     * @dev Cannot recreate the same offer. Top up or cancel the existing offer.
     */
    error OfferAlreadyExists(bytes32 offerId);

    /**
     * @dev Emmited when
     * - offer is created on source chain
     * - offer created message came to destination chain.
     */
    event OfferCreated(bytes32 indexed offerId, Offer offer);

    /**
     * @notice Creates a new offer.
     * @param _params The parameters for the createOffer() operation.
     * @param _fee The fee information supplied by the caller.
     *      - nativeFee: The native fee.
     *      - lzTokenFee: The lzToken fee.
     * @return msgReceipt The LayerZero messaging receipt from the send() operation.
     * @return createOfferReceipt The CreateOffer receipt information.
     *
     * @dev MessagingReceipt: LayerZero msg receipt
     *  - guid: The unique identifier for the sent message.
     *  - nonce: The nonce of the sent message.
     *  - fee: The LayerZero fee incurred for the message.
     *
     * @dev CreateOfferReceipt: BF OtcMarket create offer receipt
     *  - offerId: The unique global identifier of the created offer.
        - amountLD: The amount actually taken from the advertiser.
     */
    function createOffer(
        CreateOfferParams calldata _params,
        MessagingFee calldata _fee
    ) external payable returns (MessagingReceipt memory msgReceipt, CreateOfferReceipt memory createOfferReceipt);

    /**
     * @notice Provides a quote for the createOffer() operation.
     * @param _advertiser The address of the advertiser.
     * @param _params The parameters for the createOffer() operation.
     * @param _payInLzToken Flag indicating whether the caller is paying in the LZ token.
     * @return fee The calculated LayerZero messaging fee from the send() operation.
     *
     * @dev MessagingFee: LayerZero msg fee
     *  - nativeFee: The native fee.
     *  - lzTokenFee: The lzToken fee.
     */
    function quoteCreateOffer(
        bytes32 _advertiser,
        CreateOfferParams calldata _params,
        bool _payInLzToken
    ) external view returns (MessagingFee memory fee);
}
