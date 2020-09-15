pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

import "./BulkWhitelistedRole.sol";
import "../controllers/IMintingController.sol";
import "../controllers/MintingController.sol";
import "../Registry.sol";
import "../Resolver.sol";

/**
 * @title WhitelistedMinter
 * @dev Defines the functions for distribution of Second Level Domains (SLD)s.
 */
contract WhitelistedMinter is IMintingController, BulkWhitelistedRole {
    string public constant NAME = 'Unstoppable Whitelisted Minter';
    string public constant VERSION = '0.2.0';

    MintingController internal _mintingController;
    Resolver internal _resolver;
    Registry internal _registry;

    constructor(MintingController mintingController) public {
        _mintingController = mintingController;
        _registry = Registry(mintingController.registry());
    }

    function renounceMinter() external onlyWhitelistAdmin {
        _mintingController.renounceMinter();
    }

    /**
     * Renounce whitelisted account with funds' forwarding
     */
    function closeWhitelisted(address payable receiver)
        external
        payable
        onlyWhitelisted
    {
        require(receiver != address(0x0), "WhitelistedMinter: RECEIVER_IS_EMPTY");

        renounceWhitelisted();
        receiver.transfer(msg.value);
    }

    /**
     * Replace whitelisted account by new account with funds' forwarding
     */
    function rotateWhitelisted(address payable receiver)
        external
        payable
        onlyWhitelisted
    {
        require(receiver != address(0x0), "WhitelistedMinter: RECEIVER_IS_EMPTY");

        _addWhitelisted(receiver);
        renounceWhitelisted();
        receiver.transfer(msg.value);
    }

    function mintSLD(address to, string calldata label)
        external
        onlyWhitelisted
    {
        _mintingController.mintSLD(to, label);
    }

    function mintSLD(
        address to,
        string memory label,
        address resolver
    ) public onlyWhitelisted {
        _mintingController.mintSLDWithResolver(to, label, resolver);
    }

    function safeMintSLD(address to, string calldata label)
        external
        onlyWhitelisted
    {
        _mintingController.safeMintSLD(to, label);
    }

    function safeMintSLD(
        address to,
        string memory label,
        address resolver
    ) public onlyWhitelisted {
        _mintingController.safeMintSLDWithResolver(to, label, resolver);
    }

    function safeMintSLD(
        address to,
        string calldata label,
        bytes calldata _data
    ) external onlyWhitelisted {
        _mintingController.safeMintSLD(to, label, _data);
    }

    function safeMintSLD(
        address to,
        string memory label,
        bytes memory _data,
        address resolver
    ) public onlyWhitelisted {
        _mintingController.safeMintSLDWithResolver(to, label, resolver, _data);
    }

    function mintSLDToDefaultResolver(
        address to,
        string memory label,
        string[] memory keys,
        string[] memory values
    ) public onlyWhitelisted {
        mintSLDToResolver(to, label, keys, values, address(_resolver));
    }

    function mintSLDToResolver(
        address to,
        string memory label,
        string[] memory keys,
        string[] memory values,
        address resolver
    ) public onlyWhitelisted {
        _mintingController.mintSLDWithResolver(to, label, resolver);
        configResolver(label, keys, values, resolver);
    }

    function safeMintSLDToDefaultResolver(
        address to,
        string memory label,
        string[] memory keys,
        string[] memory values
    ) public onlyWhitelisted {
        safeMintSLDToResolver(to, label, keys, values, address(_resolver));
    }

    function safeMintSLDToResolver(
        address to,
        string memory label,
        string[] memory keys,
        string[] memory values,
        address resolver
    ) public onlyWhitelisted {
        _mintingController.safeMintSLDWithResolver(to, label, resolver);
        configResolver(label, keys, values, resolver);
    }

    function safeMintSLDToDefaultResolver(
        address to,
        string memory label,
        string[] memory keys,
        string[] memory values,
        bytes memory _data
    ) public onlyWhitelisted {
        safeMintSLDToResolver(to, label, keys, values, _data, address(_resolver));
    }

    function safeMintSLDToResolver(
        address to,
        string memory label,
        string[] memory keys,
        string[] memory values,
        bytes memory _data,
        address resolver
    ) public onlyWhitelisted {
        _mintingController.safeMintSLDWithResolver(to, label, resolver, _data);
        configResolver(label, keys, values, resolver);
    }

    function setDefaultResolver(address resolver) external onlyWhitelistAdmin {
        _resolver = Resolver(resolver);
    }

    function configResolver(
        string memory label,
        string[] memory keys,
        string[] memory values,
        address resolver
    ) private {
        if(keys.length == 0) {
            return;
        }

        Resolver(resolver).preconfigure(keys, values, _registry.childIdOf(_registry.root(), label));
    }
}
