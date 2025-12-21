#!/usr/bin/env node

/**
 * Test Runner Script for Trekka Server
 *
 * This script provides a convenient way to run tests with formatted output
 * and summary reporting for presentations.
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import fs from 'fs';
import path from 'path';

const execAsync = promisify(exec);

const COLORS = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

function colorize(text, color) {
    return `${COLORS[color]}${text}${COLORS.reset}`;
}

function printHeader() {
    console.log('\n');
    console.log(colorize('╔═══════════════════════════════════════════════════════════════════════════╗', 'cyan'));
    console.log(colorize('║                      TREKKA SERVER TEST SUITE                            ║', 'cyan'));
    console.log(colorize('╚═══════════════════════════════════════════════════════════════════════════╝', 'cyan'));
    console.log('\n');
}

function printSection(title) {
    console.log('\n' + colorize('═'.repeat(80), 'blue'));
    console.log(colorize(`  ${title}`, 'bright'));
    console.log(colorize('═'.repeat(80), 'blue') + '\n');
}

async function runTests() {
    printHeader();

    const startTime = Date.now();

    try {
        printSection('🚀 Starting Test Execution');

        console.log(colorize('  📂 Test Location:', 'yellow'), 'tests/trip.service.test.js');
        console.log(colorize('  🔧 Test Framework:', 'yellow'), 'AVA');
        console.log(colorize('  🗄️  Database:', 'yellow'), 'PostgreSQL with Sequelize ORM');
        console.log('\n');

        printSection('📊 Running Tests...');

        const { stdout, stderr } = await execAsync('npm test tests/trip.service.test.js', {
            cwd: path.resolve(process.cwd()),
            maxBuffer: 1024 * 1024 * 10 // 10MB buffer
        });

        console.log(stdout);
        if (stderr && !stderr.includes('DeprecationWarning')) {
            console.error(colorize('Warnings:', 'yellow'), stderr);
        }

        const endTime = Date.now();
        const duration = ((endTime - startTime) / 1000).toFixed(2);

        printSection('✅ Test Execution Complete');

        console.log(colorize('  ⏱️  Total Duration:', 'green'), `${duration} seconds`);
        console.log(colorize('  📈 Status:', 'green'), 'All tests passed successfully!');

        // Try to extract test count from output
        const testCountMatch = stdout.match(/(\d+) tests? passed/);
        if (testCountMatch) {
            console.log(colorize('  📋 Tests Executed:', 'green'), testCountMatch[1]);
        }

        printSection('📸 Results Ready for Presentation');
        console.log(colorize('  ✓', 'green'), 'Detailed test parameters logged above');
        console.log(colorize('  ✓', 'green'), 'Test results in JSON format');
        console.log(colorize('  ✓', 'green'), 'Summary statistics included');
        console.log(colorize('  ✓', 'green'), 'Ready to capture for slides/documentation');

        console.log('\n' + colorize('═'.repeat(80), 'green') + '\n');

    } catch (error) {
        const endTime = Date.now();
        const duration = ((endTime - startTime) / 1000).toFixed(2);

        printSection('❌ Test Execution Failed');

        console.log(colorize('  ⏱️  Duration:', 'red'), `${duration} seconds`);
        console.log(colorize('  ❌ Error:', 'red'), error.message);

        if (error.stdout) {
            console.log('\n' + colorize('Standard Output:', 'yellow'));
            console.log(error.stdout);
        }

        if (error.stderr) {
            console.log('\n' + colorize('Error Output:', 'red'));
            console.log(error.stderr);
        }

        console.log('\n' + colorize('═'.repeat(80), 'red') + '\n');
        process.exit(1);
    }
}

// Check if tests directory exists
const testsDir = path.join(process.cwd(), 'tests');
if (!fs.existsSync(testsDir)) {
    console.error(colorize('\n❌ Error: tests directory not found!', 'red'));
    console.log(colorize('\n  Please ensure you are running this from the server directory.', 'yellow'));
    process.exit(1);
}

// Run the tests
runTests();

