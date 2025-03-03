import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test player creation and duplicate prevention",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('game-trek', 'create-player', 
        [types.ascii("Hero1"), types.uint(100), types.uint(80), types.uint(70)],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk();
    
    // Try creating duplicate player
    block = chain.mineBlock([
      Tx.contractCall('game-trek', 'create-player',
        [types.ascii("Hero2"), types.uint(100), types.uint(80), types.uint(70)],
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectErr(types.uint(100));
  }
});

Clarinet.test({
  name: "Test quest system with location validation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    // Create player
    chain.mineBlock([
      Tx.contractCall('game-trek', 'create-player',
        [types.ascii("Hero1"), types.uint(100), types.uint(80), types.uint(70)],
        deployer.address
      )
    ]);
    
    // Add quest
    let block = chain.mineBlock([
      Tx.contractCall('game-trek', 'add-quest',
        [types.uint(1), types.ascii("Test Quest"), types.uint(50), types.uint(1), types.uint(1)],
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectOk();
    
    // Move to quest location
    block = chain.mineBlock([
      Tx.contractCall('game-trek', 'move-location',
        [types.uint(1)],
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectOk();
    
    // Complete quest
    block = chain.mineBlock([
      Tx.contractCall('game-trek', 'start-quest',
        [types.uint(1)],
        deployer.address
      )
    ]);
    
    block.receipts[0].result.expectOk();
  }
});
