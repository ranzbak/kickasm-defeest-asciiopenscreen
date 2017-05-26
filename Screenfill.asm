BasicUpstart2(begin)      // <- This creates a basic sys line that can start your program

// constants
.const MASK = $FB

// registers
.const MEMSETREG = $D018 // VIC memory layout register

// Counter
charcnt: .byte 0   // String position
scrcnt:  .byte 0   // Screen position
wcnt:    .byte 0   // Word count

// Start of the main program
* = $4000 "Main Program"    // <- The name 'Main program' will appear in the memory map when assembling   jsr clear
begin:  
  lda #%00010111      // To lower case
  sta MEMSETREG     

// Put characters to the screen
loop_defeest:
  ldx #0            // Reset string position
  stx charcnt       

loop_text:
  // Prepare bit mask
  lda charcnt       // Get the loop count from memory
  and #%00000111    // Mask to % 8 
  adc #1            // 
  tax
  lda #%00000001    // Store value into zero page
rolloop:
  asl               // Rol left ACC 
  dex               // DEC X reg
  bne rolloop       // 0 Yet?
  sta MASK          // Store the generated bit mask
  
  // Get char from string
  lda wcnt          // Get the charcount to compare against
  and MASK          // AND bitmask with ACC
  beq !islower+     // If zero it's lower

// The char is upper case
  ldx charcnt       // Retrieve the pointer position in the string
  lda dtext,x       // Get char from text
  jmp !toscreen+    // To the screen!

!islower:
  ldx charcnt       // Retrieve the pointer position in the string
  lda dtext,x       // Get char from text
  cmp #33           // ! char

  beq !toscreen+
  cmp #32           // ' ' char
  beq !toscreen+

  sec
  sbc #$40          // to upper

!toscreen:
  ldx scrcnt        // Restore screen pos
  sta scroffset:$0400,x       // Put char on screen

  inc scrcnt        // Next pos on the screen
  bne !over+ // Next bank to write to
  inc scroffset+1
!over:

  inc charcnt       // Next char in string
  ldx charcnt
  cpx #$07
  bne loop_text     // End ??

  inc wcnt           // next word
  ldx wcnt
  cpx #$92         // Print 'defeest' 16 times
  bne loop_defeest  // Print the next word

  // Wait for a few screen blanks
  ldx #$FF
!mainloop:
  clc
  lda #$10
!rasloop:  
  cmp $d012
  bne !rasloop-
  dex
  bne !mainloop- 

// Clear the screen
  lda #$20
!loop:   
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  dex
  bne !loop-

  lda #%00010101      // To upper case
  sta MEMSETREG     

  rts               // Exit

// Text to permutate
dtext:
  .text "DEFEEST"
