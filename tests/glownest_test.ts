import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test sleep logging functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('glownest', 'log-sleep', 
        [types.uint(8), types.uint(85)], 
        user.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify points
    let response = chain.callReadOnlyFn(
      'glownest',
      'get-points',
      [types.principal(user.address)],
      user.address
    );
    response.result.expectOk().expectUint(10);
  }
});

Clarinet.test({
  name: "Test hydration logging functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('glownest', 'log-hydration',
        [types.uint(500)],
        user.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify points
    let response = chain.callReadOnlyFn(
      'glownest',
      'get-points',
      [types.principal(user.address)],
      user.address
    );
    response.result.expectOk().expectUint(5);
  }
});

Clarinet.test({
  name: "Test mindfulness logging functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('glownest', 'log-mindfulness',
        [types.uint(20)],
        user.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify points
    let response = chain.callReadOnlyFn(
      'glownest',
      'get-points',
      [types.principal(user.address)],
      user.address
    );
    response.result.expectOk().expectUint(15);
  }
});

Clarinet.test({
  name: "Test invalid inputs",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user = accounts.get('wallet_1')!;
    
    // Test invalid sleep hours
    let block = chain.mineBlock([
      Tx.contractCall('glownest', 'log-sleep',
        [types.uint(25), types.uint(85)],
        user.address
      )
    ]);
    block.receipts[0].result.expectErr().expectUint(101);
    
    // Test invalid hydration
    block = chain.mineBlock([
      Tx.contractCall('glownest', 'log-hydration',
        [types.uint(0)],
        user.address
      )
    ]);
    block.receipts[0].result.expectErr().expectUint(103);
    
    // Test invalid mindfulness minutes
    block = chain.mineBlock([
      Tx.contractCall('glownest', 'log-mindfulness',
        [types.uint(0)],
        user.address
      )
    ]);
    block.receipts[0].result.expectErr().expectUint(104);
  }
});
