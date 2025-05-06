import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract environment
const mockBlockTime = 1620000000;
const mockTxSender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';

// Mock contract state
let lastComponentId = 0;
const components = new Map();

// Mock contract functions
function addComponent(partNumber: string, manufacturer: string, batchNumber: string) {
  const newId = lastComponentId + 1;
  lastComponentId = newId;
  
  components.set(newId, {
    'part-number': partNumber,
    'manufacturer': manufacturer,
    'batch-number': batchNumber,
    'timestamp': mockBlockTime,
    'added-by': mockTxSender
  });
  
  return { type: 'ok', value: newId };
}

function getComponent(componentId: number) {
  return components.get(componentId) || null;
}

function getComponentCount() {
  return lastComponentId;
}

describe('Component Tracking Contract', () => {
  beforeEach(() => {
    // Reset state before each test
    lastComponentId = 0;
    components.clear();
  });
  
  it('should add a component and return the new ID', () => {
    const result = addComponent('PART-123', 'ACME Inc.', 'BATCH-456');
    expect(result.type).toBe('ok');
    expect(result.value).toBe(1);
    expect(getComponentCount()).toBe(1);
  });
  
  it('should retrieve a component by ID', () => {
    addComponent('PART-123', 'ACME Inc.', 'BATCH-456');
    const component = getComponent(1);
    
    expect(component).not.toBeNull();
    expect(component['part-number']).toBe('PART-123');
    expect(component['manufacturer']).toBe('ACME Inc.');
    expect(component['batch-number']).toBe('BATCH-456');
    expect(component['timestamp']).toBe(mockBlockTime);
    expect(component['added-by']).toBe(mockTxSender);
  });
  
  it('should return null for non-existent component', () => {
    const component = getComponent(999);
    expect(component).toBeNull();
  });
  
  it('should increment component IDs correctly', () => {
    addComponent('PART-123', 'ACME Inc.', 'BATCH-456');
    addComponent('PART-124', 'ACME Inc.', 'BATCH-457');
    addComponent('PART-125', 'ACME Inc.', 'BATCH-458');
    
    expect(getComponentCount()).toBe(3);
    
    const component1 = getComponent(1);
    const component2 = getComponent(2);
    const component3 = getComponent(3);
    
    expect(component1['part-number']).toBe('PART-123');
    expect(component2['part-number']).toBe('PART-124');
    expect(component3['part-number']).toBe('PART-125');
  });
});
