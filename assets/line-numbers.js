document.addEventListener('DOMContentLoaded', function() {
    const codeBlocks = document.querySelectorAll('pre > code');

    codeBlocks.forEach(function(codeBlock) {
        const pre = codeBlock.parentElement;
        
        // Check if already processed
        if (pre.querySelector('.line-numbers-rows')) return;

        // Clone to count lines correctly handling <br>
        const clone = codeBlock.cloneNode(true);
        const brs = clone.querySelectorAll('br');
        brs.forEach(br => br.replaceWith('\n'));
        
        const text = clone.textContent;
        // Remove trailing newline if it exists to avoid extra line number
        const cleanText = text.replace(/\n$/, '');
        const lineCount = cleanText.split(/\r\n|\r|\n/).length;
        
        // Create line numbers container
        const rows = document.createElement('span');
        rows.className = 'line-numbers-rows';
        
        for (let i = 1; i <= lineCount; i++) {
            const span = document.createElement('span');
            span.textContent = i;
            rows.appendChild(span);
        }
        
        // Insert before code block
        pre.insertBefore(rows, codeBlock);
        pre.classList.add('has-line-numbers');
    });
});
