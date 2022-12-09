import { expect } from "chai";
import { setupERC721RugGripper } from "../fixture/setup-contracts";

describe("ERC721RugGripper", function () {
  let tx, receipt, gasFee;

  it("Positive: reMint", async function () {
    const {
      provider,
      contract,
      beneficiary,
      users,
      maxSupply,
      mintPrice,
      startVestingTime,
      duration
    } = await setupERC721RugGripper();
    if (!provider) return;
    const mintAmount = 3;
    const backAmount = 2;
    const leftAmount = mintAmount - backAmount;

    tx = await contract.connect(users[1]).publicMint(mintAmount, { value: mintPrice.mul(mintAmount) });
    await tx.wait();
    expect(await contract.balanceOf(users[1].address))
    .equal(mintAmount);
    expect(await provider.getBalance(contract.address))
    .equal(mintPrice.mul(mintAmount));

    tx = await contract.connect(users[1]).redeem([0,1]);
    await tx.wait();
    expect(await contract.balanceOf(users[1].address))
    .equal(leftAmount);
    expect(await contract.balanceOf(contract.address))
    .equal(backAmount);
    expect(await provider.getBalance(contract.address))
    .equal(mintPrice.mul(leftAmount));

    tx = await contract.connect(users[2]).reMint([0,1], { value: mintPrice.mul(backAmount) });
    await tx.wait();
    expect(await contract.balanceOf(users[2].address))
    .equal(backAmount);
    expect(await contract.balanceOf(contract.address))
    .equal(0);
    expect(await provider.getBalance(contract.address))
    .equal(mintPrice.mul(mintAmount));
  });
});
