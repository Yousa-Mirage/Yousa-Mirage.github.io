document.addEventListener('DOMContentLoaded', function() {
    // Find all code blocks
    const codeBlocks = document.querySelectorAll('pre > code');

    codeBlocks.forEach(function(codeBlock) {
        // Create container for the copy button
        const buttonContainer = document.createElement('div');
        buttonContainer.className = 'copy-button-container';
        
        // Create the copy button
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-button';
        copyButton.textContent = 'Copy';
        
        // Add click event listener
        copyButton.addEventListener('click', function() {
            // Clone the code block to handle <br> tags correctly
            const clone = codeBlock.cloneNode(true);
            
            // Replace <br> tags with newlines
            const brs = clone.querySelectorAll('br');
            brs.forEach(br => {
                br.replaceWith('\n');
            });

            // Get text content (now with newlines)
            const codeText = clone.textContent;
            
            navigator.clipboard.writeText(codeText).then(function() {
                // Success feedback
                const originalText = copyButton.textContent;
                copyButton.textContent = 'Copied!';
                copyButton.classList.add('copied');
                
                setTimeout(function() {
                    copyButton.textContent = originalText;
                    copyButton.classList.remove('copied');
                }, 2000);
            }).catch(function(err) {
                console.error('Failed to copy text: ', err);
                copyButton.textContent = 'Error';
            });
        });

        // Insert the button before the code block (or inside the pre, depending on layout)
        // Since the structure is <figure><pre><code>...</code></pre></figure> or just <pre><code>...</code></pre>
        // We want the button to be positioned relative to the pre.
        
        const pre = codeBlock.parentElement;
        
        // Make sure pre is positioned relatively so we can absolute position the button
        pre.style.position = 'relative';
        
        // Append button to pre
        pre.appendChild(copyButton);
    });
});
