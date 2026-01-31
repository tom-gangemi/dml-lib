<template>
  <div class="dml-graph-container">
    <div class="graph-wrapper">
      <svg viewBox="0 0 800 400" class="dependency-graph">
        <!-- Edges -->
        <defs>
          <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
            <polygon points="0 0, 10 3.5, 0 7" fill="#666" />
          </marker>
        </defs>
        
        <!-- Edge lines -->
        <g class="edges">
          <line v-for="edge in edges" :key="edge.id"
            :x1="getNodePosition(edge.from).x" 
            :y1="getNodePosition(edge.from).y"
            :x2="getNodePosition(edge.to).x" 
            :y2="getNodePosition(edge.to).y"
            :class="{ 'edge-highlighted': isEdgeHighlighted(edge) }"
            marker-end="url(#arrowhead)"
          />
        </g>
        
        <!-- Nodes -->
        <g v-for="node in nodes" :key="node.id" 
           :transform="`translate(${getNodePosition(node.id).x}, ${getNodePosition(node.id).y})`"
           class="node"
           :class="{ 
             'node-active': isNodeActive(node.id),
             'node-completed': isNodeCompleted(node.id),
             'node-pending': isNodePending(node.id)
           }">
          <circle r="24" :fill="getNodeColor(node.id)" />
          <text dy="5" text-anchor="middle" fill="white" font-weight="bold" font-size="12">
            {{ node.id }}
          </text>
        </g>
      </svg>
    </div>
    
    <div class="controls">
      <button @click="reset" class="btn btn-reset" :disabled="currentStep === 0">
        Reset
      </button>
      <button @click="prevStep" class="btn btn-prev" :disabled="currentStep === 0">
        ← Previous
      </button>
      <button @click="nextStep" class="btn btn-next" :disabled="currentStep >= steps.length">
        Next →
      </button>
      <button @click="playAll" class="btn btn-play" :disabled="isPlaying || currentStep >= steps.length">
        {{ isPlaying ? 'Playing...' : '▶ Play All' }}
      </button>
    </div>
    
    <div class="execution-log">
      <div class="log-header">Execution Log</div>
      <div class="log-entries">
        <div v-for="(step, index) in steps" :key="index"
             class="log-entry"
             :class="{ 
               'log-current': index === currentStep - 1,
               'log-completed': index < currentStep - 1,
               'log-pending': index >= currentStep
             }">
          <span class="log-number">{{ index + 1 }}.</span>
          <span class="log-color" :style="{ backgroundColor: step.color }"></span>
          <span class="log-operation">{{ step.operation }}</span>
          <span class="log-sobject">{{ step.sobject }}</span>
          <span class="log-records">{{ step.records.join(', ') }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const currentStep = ref(0)
const isPlaying = ref(false)

const nodes = [
  { id: 'A1' }, { id: 'A2' }, { id: 'A3' }, { id: 'A4' }, 
  { id: 'A5' }, { id: 'A6' }, { id: 'A7' }, { id: 'A8' },
  { id: 'C1' }, { id: 'C2' }, { id: 'C3' }, { id: 'C4' },
  { id: 'O1' }, { id: 'O2' }, { id: 'O3' }, { id: 'O4' },
  { id: 'L1' }
]

const edges = [
  { id: 'e1', from: 'A2', to: 'A1' },
  { id: 'e2', from: 'A4', to: 'A2' },
  { id: 'e3', from: 'A5', to: 'A2' },
  { id: 'e4', from: 'A3', to: 'A5' },
  { id: 'e5', from: 'A6', to: 'A5' },
  { id: 'e6', from: 'A7', to: 'A5' },
  { id: 'e7', from: 'C1', to: 'A2' },
  { id: 'e8', from: 'C2', to: 'A3' },
  { id: 'e9', from: 'C3', to: 'A6' },
  { id: 'e10', from: 'C4', to: 'A6' },
  { id: 'e11', from: 'O1', to: 'A1' },
  { id: 'e12', from: 'O2', to: 'A4' },
  { id: 'e13', from: 'O3', to: 'A6' },
  { id: 'e14', from: 'O4', to: 'A6' }
]

const steps = [
  { operation: 'INSERT', sobject: 'Account', records: ['A1', 'A8'], color: '#4CAF50' },
  { operation: 'INSERT', sobject: 'Lead', records: ['L1'], color: '#F44336' },
  { operation: 'UPSERT', sobject: 'Account', records: ['A2'], color: '#FF9800' },
  { operation: 'INSERT', sobject: 'Opportunity', records: ['O1'], color: '#9C27B0' },
  { operation: 'UPSERT', sobject: 'Account', records: ['A4'], color: '#795548' },
  { operation: 'INSERT', sobject: 'Account', records: ['A5'], color: '#00BCD4' },
  { operation: 'INSERT', sobject: 'Contact', records: ['C1'], color: '#2196F3' },
  { operation: 'UPSERT', sobject: 'Account', records: ['A3'], color: '#607D8B' },
  { operation: 'INSERT', sobject: 'Account', records: ['A6', 'A7'], color: '#8BC34A' },
  { operation: 'INSERT', sobject: 'Opportunity', records: ['O2'], color: '#E91E63' },
  { operation: 'INSERT', sobject: 'Contact', records: ['C2', 'C3', 'C4'], color: '#009688' },
  { operation: 'INSERT', sobject: 'Opportunity', records: ['O3', 'O4'], color: '#3F51B5' }
]

const nodePositions = {
  // Layer 1 - No dependencies
  'A1': { x: 100, y: 100 },
  'A8': { x: 100, y: 200 },
  'L1': { x: 100, y: 300 },
  // Layer 2
  'A2': { x: 250, y: 100 },
  'O1': { x: 250, y: 200 },
  // Layer 3
  'A4': { x: 400, y: 50 },
  'A5': { x: 400, y: 150 },
  'C1': { x: 400, y: 250 },
  // Layer 4
  'A3': { x: 550, y: 80 },
  'A6': { x: 550, y: 180 },
  'A7': { x: 550, y: 280 },
  'O2': { x: 550, y: 350 },
  // Layer 5
  'C2': { x: 700, y: 50 },
  'C3': { x: 700, y: 150 },
  'C4': { x: 700, y: 220 },
  'O3': { x: 700, y: 300 },
  'O4': { x: 700, y: 370 }
}

const completedNodes = computed(() => {
  const completed = new Set()
  for (let i = 0; i < currentStep.value; i++) {
    steps[i].records.forEach(r => completed.add(r))
  }
  return completed
})

const activeNodes = computed(() => {
  if (currentStep.value === 0 || currentStep.value > steps.length) return new Set()
  return new Set(steps[currentStep.value - 1].records)
})

function getNodePosition(nodeId) {
  return nodePositions[nodeId] || { x: 0, y: 0 }
}

function getNodeColor(nodeId) {
  if (activeNodes.value.has(nodeId)) {
    const step = steps[currentStep.value - 1]
    return step.color
  }
  if (completedNodes.value.has(nodeId)) {
    for (let i = currentStep.value - 2; i >= 0; i--) {
      if (steps[i].records.includes(nodeId)) {
        return steps[i].color
      }
    }
  }
  return '#374151'
}

function isNodeActive(nodeId) {
  return activeNodes.value.has(nodeId)
}

function isNodeCompleted(nodeId) {
  return completedNodes.value.has(nodeId) && !activeNodes.value.has(nodeId)
}

function isNodePending(nodeId) {
  return !completedNodes.value.has(nodeId) && !activeNodes.value.has(nodeId)
}

function isEdgeHighlighted(edge) {
  return (activeNodes.value.has(edge.from) || completedNodes.value.has(edge.from)) &&
         (activeNodes.value.has(edge.to) || completedNodes.value.has(edge.to))
}

function nextStep() {
  if (currentStep.value < steps.length) {
    currentStep.value++
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

function reset() {
  currentStep.value = 0
  isPlaying.value = false
}

async function playAll() {
  isPlaying.value = true
  currentStep.value = 0
  
  for (let i = 0; i < steps.length; i++) {
    if (!isPlaying.value) break
    await new Promise(resolve => setTimeout(resolve, 800))
    currentStep.value++
  }
  
  isPlaying.value = false
}
</script>

<style scoped>
.dml-graph-container {
  margin: 2rem 0;
  font-family: var(--vp-font-family-base);
}

.graph-wrapper {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 1rem;
  margin-bottom: 1rem;
  overflow-x: auto;
}

.dependency-graph {
  width: 100%;
  max-width: 800px;
  height: auto;
  display: block;
  margin: 0 auto;
}

.edges line {
  stroke: #666;
  stroke-width: 2;
  opacity: 0.3;
  transition: all 0.3s ease;
}

.edges line.edge-highlighted {
  opacity: 1;
  stroke: #888;
}

.node {
  cursor: pointer;
  transition: all 0.3s ease;
}

.node circle {
  transition: all 0.3s ease;
  stroke: transparent;
  stroke-width: 3;
}

.node-active circle {
  stroke: #fff;
  filter: drop-shadow(0 0 8px currentColor);
  transform: scale(1.15);
}

.node-pending circle {
  opacity: 0.4;
}

.node-completed circle {
  opacity: 0.9;
}

.controls {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s ease;
  font-size: 0.9rem;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-reset {
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
}

.btn-prev, .btn-next {
  background: var(--vp-c-brand-1);
  color: white;
}

.btn-play {
  background: #4CAF50;
  color: white;
}

.btn:not(:disabled):hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.execution-log {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  overflow: hidden;
}

.log-header {
  background: var(--vp-c-bg-alt);
  padding: 0.75rem 1rem;
  font-weight: 600;
  border-bottom: 1px solid var(--vp-c-divider);
}

.log-entries {
  max-height: 400px;
  overflow-y: auto;
}

.log-entry {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.6rem 1rem;
  border-bottom: 1px solid var(--vp-c-divider);
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.log-entry:last-child {
  border-bottom: none;
}

.log-pending {
  opacity: 0.4;
}

.log-completed {
  opacity: 0.7;
}

.log-current {
  background: var(--vp-c-brand-soft);
  opacity: 1;
  font-weight: 500;
}

.log-number {
  font-weight: 600;
  min-width: 24px;
  color: var(--vp-c-text-2);
}

.log-color {
  width: 12px;
  height: 12px;
  border-radius: 3px;
  flex-shrink: 0;
}

.log-operation {
  font-weight: 600;
  min-width: 60px;
  color: var(--vp-c-text-1);
}

.log-sobject {
  color: var(--vp-c-brand-1);
  min-width: 80px;
}

.log-records {
  color: var(--vp-c-text-2);
  font-family: var(--vp-font-family-mono);
  font-size: 0.85rem;
}

@media (max-width: 640px) {
  .log-entry {
    flex-wrap: wrap;
  }
  
  .log-records {
    width: 100%;
    margin-top: 0.25rem;
    margin-left: calc(24px + 12px + 1.5rem);
  }
}
</style>
