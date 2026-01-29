// Game Engine - TypeScript port of game_rules.dart
// Server-authoritative game logic for Chain Reaction

export interface Cell {
    x: number;
    y: number;
    atomCount: number;
    ownerId: string | null;
    capacity: number;
}

export interface GameState {
    grid: Cell[][];
    currentPlayerIndex: number;
    turnNumber: number;
    isGameOver: boolean;
    winnerId: string | null;
}

export interface Player {
    id: string;
    name: string;
    colorIndex: number;
}

export interface MoveResult {
    success: boolean;
    newState: GameState;
    error?: string;
}

/**
 * Calculate cell capacity based on position
 * Corners: 1, Edges: 2, Center: 3
 */
export function calculateCapacity(x: number, y: number, rows: number, cols: number): number {
    const isCornerX = x === 0 || x === cols - 1;
    const isCornerY = y === 0 || y === rows - 1;

    if (isCornerX && isCornerY) return 1; // Corner
    if (isCornerX || isCornerY) return 2; // Edge
    return 3; // Center
}

/**
 * Initialize an empty grid
 */
export function initializeGrid(rows: number, cols: number): Cell[][] {
    const grid: Cell[][] = [];
    for (let y = 0; y < rows; y++) {
        const row: Cell[] = [];
        for (let x = 0; x < cols; x++) {
            row.push({
                x,
                y,
                atomCount: 0,
                ownerId: null,
                capacity: calculateCapacity(x, y, rows, cols),
            });
        }
        grid.push(row);
    }
    return grid;
}

/**
 * Validate a move
 */
export function validateMove(
    state: GameState,
    x: number,
    y: number,
    playerId: string,
    players: Player[]
): { valid: boolean; error?: string } {
    const rows = state.grid.length;
    const cols = state.grid[0]?.length ?? 0;

    // Bounds check
    if (y < 0 || y >= rows || x < 0 || x >= cols) {
        return { valid: false, error: 'Out of bounds' };
    }

    // Game over check
    if (state.isGameOver) {
        return { valid: false, error: 'Game is over' };
    }

    // Turn check
    const currentPlayer = players[state.currentPlayerIndex];
    if (currentPlayer.id !== playerId) {
        return { valid: false, error: 'Not your turn' };
    }

    // Cell ownership check
    const cell = state.grid[y][x];
    if (cell.ownerId !== null && cell.ownerId !== playerId) {
        return { valid: false, error: 'Cell owned by opponent' };
    }

    return { valid: true };
}

/**
 * Get orthogonal neighbors
 */
function getNeighbors(x: number, y: number, rows: number, cols: number): Array<{ x: number; y: number }> {
    const neighbors: Array<{ x: number; y: number }> = [];
    if (y > 0) neighbors.push({ x, y: y - 1 }); // Top
    if (x < cols - 1) neighbors.push({ x: x + 1, y }); // Right
    if (y < rows - 1) neighbors.push({ x, y: y + 1 }); // Bottom
    if (x > 0) neighbors.push({ x: x - 1, y }); // Left
    return neighbors;
}

/**
 * Process all explosions (chain reactions)
 */
function processExplosions(grid: Cell[][], playerId: string): Cell[][] {
    const rows = grid.length;
    const cols = grid[0].length;

    // Deep clone grid
    let currentGrid = JSON.parse(JSON.stringify(grid)) as Cell[][];
    let hasExplosions = true;
    let iterations = 0;
    const maxIterations = 1000; // Safety limit

    while (hasExplosions && iterations < maxIterations) {
        hasExplosions = false;
        iterations++;

        // Find all cells at critical mass
        const explosionQueue: Array<{ x: number; y: number }> = [];
        for (let y = 0; y < rows; y++) {
            for (let x = 0; x < cols; x++) {
                const cell = currentGrid[y][x];
                if (cell.atomCount > cell.capacity) {
                    explosionQueue.push({ x, y });
                }
            }
        }

        // Process explosions
        for (const { x, y } of explosionQueue) {
            const cell = currentGrid[y][x];
            const neighbors = getNeighbors(x, y, rows, cols);
            const atomsToRemove = neighbors.length;

            // Remove atoms from source
            cell.atomCount -= atomsToRemove;
            if (cell.atomCount <= 0) {
                cell.ownerId = null;
                cell.atomCount = 0;
            }

            // Add atoms to neighbors
            for (const n of neighbors) {
                const neighbor = currentGrid[n.y][n.x];
                neighbor.atomCount += 1;
                neighbor.ownerId = playerId; // Conquest!

                if (neighbor.atomCount > neighbor.capacity) {
                    hasExplosions = true;
                }
            }
        }
    }

    return currentGrid;
}

/**
 * Check for winner
 */
function checkWinner(grid: Cell[][], turnNumber: number): string | null {
    // No winner check on first two turns (each player needs at least one move)
    if (turnNumber < 2) return null;

    const owners = new Set<string>();
    for (const row of grid) {
        for (const cell of row) {
            if (cell.ownerId) {
                owners.add(cell.ownerId);
            }
        }
    }

    // Winner if only one player remains
    if (owners.size === 1) {
        return Array.from(owners)[0];
    }

    return null;
}

/**
 * Apply a move and return new state
 */
export function applyMove(
    state: GameState,
    x: number,
    y: number,
    playerId: string,
    playerCount: number
): GameState {
    // Deep clone grid
    let grid = JSON.parse(JSON.stringify(state.grid)) as Cell[][];

    // Place atom
    const cell = grid[y][x];
    cell.atomCount += 1;
    cell.ownerId = playerId;

    // Process chain reactions
    grid = processExplosions(grid, playerId);

    // Update turn
    const newTurnNumber = state.turnNumber + 1;
    const newPlayerIndex = (state.currentPlayerIndex + 1) % playerCount;

    // Check winner
    const winnerId = checkWinner(grid, newTurnNumber);
    const isGameOver = winnerId !== null;

    return {
        grid,
        currentPlayerIndex: isGameOver ? state.currentPlayerIndex : newPlayerIndex,
        turnNumber: newTurnNumber,
        isGameOver,
        winnerId,
    };
}
