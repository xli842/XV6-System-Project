
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:
8010000c:	0f 20 e0             	mov    %cr4,%eax
8010000f:	83 c8 10             	or     $0x10,%eax
80100012:	0f 22 e0             	mov    %eax,%cr4
80100015:	b8 00 80 12 00       	mov    $0x128000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc d0 a5 12 80       	mov    $0x8012a5d0,%esp
8010002d:	b8 2e 2b 10 80       	mov    $0x80102b2e,%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 e0 a5 12 80       	push   $0x8012a5e0
80100046:	e8 25 3c 00 00       	call   80103c70 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 30 ed 12 80    	mov    0x8012ed30,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc ec 12 80    	cmp    $0x8012ecdc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 e0 a5 12 80       	push   $0x8012a5e0
8010007c:	e8 54 3c 00 00       	call   80103cd5 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 d0 39 00 00       	call   80103a5c <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 2c ed 12 80    	mov    0x8012ed2c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc ec 12 80    	cmp    $0x8012ecdc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 e0 a5 12 80       	push   $0x8012a5e0
801000ca:	e8 06 3c 00 00       	call   80103cd5 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 82 39 00 00       	call   80103a5c <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 a0 65 10 80       	push   $0x801065a0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 b1 65 10 80       	push   $0x801065b1
80100100:	68 e0 a5 12 80       	push   $0x8012a5e0
80100105:	e8 2a 3a 00 00       	call   80103b34 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 2c ed 12 80 dc 	movl   $0x8012ecdc,0x8012ed2c
80100111:	ec 12 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 30 ed 12 80 dc 	movl   $0x8012ecdc,0x8012ed30
8010011b:	ec 12 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 a6 12 80       	mov    $0x8012a614,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 dc ec 12 80 	movl   $0x8012ecdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 b8 65 10 80       	push   $0x801065b8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 e1 38 00 00       	call   80103a29 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 30 ed 12 80    	mov    %ebx,0x8012ed30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc ec 12 80    	cmp    $0x8012ecdc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 83 1c 00 00       	call   80101e18 <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 39 39 00 00       	call   80103ae6 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 58 1c 00 00       	call   80101e18 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 bf 65 10 80       	push   $0x801065bf
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 fd 38 00 00       	call   80103ae6 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 b2 38 00 00       	call   80103aab <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 a5 12 80 	movl   $0x8012a5e0,(%esp)
80100200:	e8 6b 3a 00 00       	call   80103c70 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 dc ec 12 80 	movl   $0x8012ecdc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 30 ed 12 80    	mov    %ebx,0x8012ed30
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 a5 12 80       	push   $0x8012a5e0
8010024c:	e8 84 3a 00 00       	call   80103cd5 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 c6 65 10 80       	push   $0x801065c6
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 cf 13 00 00       	call   8010164f <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 95 12 80 	movl   $0x80129520,(%esp)
8010028a:	e8 e1 39 00 00       	call   80103c70 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ef 12 80       	mov    0x8012efc0,%eax
8010029f:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 22 30 00 00       	call   801032ce <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 95 12 80       	push   $0x80129520
801002ba:	68 c0 ef 12 80       	push   $0x8012efc0
801002bf:	e8 b1 34 00 00       	call   80103775 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 12 80       	push   $0x80129520
801002d1:	e8 ff 39 00 00       	call   80103cd5 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 af 12 00 00       	call   8010158d <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 c0 ef 12 80    	mov    %edx,0x8012efc0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 ef 12 80 	movzbl -0x7fed10c0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 c0 ef 12 80       	mov    %eax,0x8012efc0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 95 12 80       	push   $0x80129520
80100331:	e8 9f 39 00 00       	call   80103cd5 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 4f 12 00 00       	call   8010158d <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 95 12 80 00 	movl   $0x0,0x80129554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 e4 20 00 00       	call   80102443 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 cd 65 10 80       	push   $0x801065cd
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 1b 6f 10 80 	movl   $0x80106f1b,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 bb 37 00 00       	call   80103b4f <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 e1 65 10 80       	push   $0x801065e1
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 95 12 80 01 	movl   $0x1,0x80129558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 e5 65 10 80       	push   $0x801065e5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 d8 38 00 00       	call   80103d97 <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 3e 38 00 00       	call   80103d1c <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 95 12 80 00 	cmpl   $0x0,0x80129558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 4b 4c 00 00       	call   80105156 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 32 4c 00 00       	call   80105156 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 26 4c 00 00       	call   80105156 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 1a 4c 00 00       	call   80105156 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 10 66 10 80 	movzbl -0x7fef99f0(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 8c 10 00 00       	call   8010164f <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 95 12 80 	movl   $0x80129520,(%esp)
801005ca:	e8 a1 36 00 00       	call   80103c70 <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 95 12 80       	push   $0x80129520
801005f1:	e8 df 36 00 00       	call   80103cd5 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 8c 0f 00 00       	call   8010158d <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 95 12 80       	mov    0x80129554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 95 12 80       	push   $0x80129520
80100638:	e8 33 36 00 00       	call   80103c70 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 ff 65 10 80       	push   $0x801065ff
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be f8 65 10 80       	mov    $0x801065f8,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 95 12 80       	push   $0x80129520
80100734:	e8 9c 35 00 00       	call   80103cd5 <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 95 12 80       	push   $0x80129520
8010074f:	e8 1c 35 00 00       	call   80103c70 <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 ef 12 80    	sub    0x8012efc0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 ef 12 80    	mov    %edx,0x8012efc8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 ef 12 80    	mov    %cl,-0x7fed10c0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 c0 ef 12 80       	mov    0x8012efc0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 ef 12 80    	cmp    %eax,0x8012efc8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
801007d1:	a3 c4 ef 12 80       	mov    %eax,0x8012efc4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 ef 12 80       	push   $0x8012efc0
801007de:	e8 f7 30 00 00       	call   801038da <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 c8 ef 12 80       	mov    %eax,0x8012efc8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
801007fc:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 40 ef 12 80 0a 	cmpb   $0xa,-0x7fed10c0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
8010084f:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 ef 12 80       	mov    %eax,0x8012efc8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 95 12 80       	push   $0x80129520
80100873:	e8 5d 34 00 00       	call   80103cd5 <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 eb 30 00 00       	call   80103977 <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 08 66 10 80       	push   $0x80106608
80100899:	68 20 95 12 80       	push   $0x80129520
8010089e:	e8 91 32 00 00       	call   80103b34 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 8c f9 12 80 ac 	movl   $0x801005ac,0x8012f98c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 88 f9 12 80 68 	movl   $0x80100268,0x8012f988
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 95 12 80 01 	movl   $0x1,0x80129554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 bd 16 00 00       	call   80101f8a <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 eb 29 00 00       	call   801032ce <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 85 1f 00 00       	call   80102873 <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 f4 12 00 00       	call   80101bed <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 82 0c 00 00       	call   8010158d <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 63 0e 00 00       	call   8010177f <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 e9 02 00 00    	je     80100c15 <exec+0x343>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 ff 0d 00 00       	call   80101734 <iunlockput>
    end_op();
80100935:	e8 b3 1f 00 00       	call   801028ed <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 9e 1f 00 00       	call   801028ed <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 21 66 10 80       	push   $0x80106621
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 b5 59 00 00       	call   8010632c <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 12 01 00 00    	je     80100a97 <exec+0x1c5>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 9e 00 00 00    	jle    80100a50 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 b7 0d 00 00       	call   8010177f <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 c3 00 00 00    	jne    80100a97 <exec+0x1c5>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 a8 00 00 00    	jb     80100a97 <exec+0x1c5>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 9c 00 00 00    	jb     80100a97 <exec+0x1c5>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz, curproc->pid)) == 0)  // revise
801009fb:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a01:	ff 71 10             	pushl  0x10(%ecx)
80100a04:	50                   	push   %eax
80100a05:	57                   	push   %edi
80100a06:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a0c:	e8 b8 57 00 00       	call   801061c9 <allocuvm>
80100a11:	89 c7                	mov    %eax,%edi
80100a13:	83 c4 10             	add    $0x10,%esp
80100a16:	85 c0                	test   %eax,%eax
80100a18:	74 7d                	je     80100a97 <exec+0x1c5>
    if(ph.vaddr % PGSIZE != 0)
80100a1a:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a20:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a25:	75 70                	jne    80100a97 <exec+0x1c5>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a27:	83 ec 0c             	sub    $0xc,%esp
80100a2a:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a30:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a36:	53                   	push   %ebx
80100a37:	50                   	push   %eax
80100a38:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a3e:	e8 54 56 00 00       	call   80106097 <loaduvm>
80100a43:	83 c4 20             	add    $0x20,%esp
80100a46:	85 c0                	test   %eax,%eax
80100a48:	0f 89 49 ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a4e:	eb 47                	jmp    80100a97 <exec+0x1c5>
  iunlockput(ip);
80100a50:	83 ec 0c             	sub    $0xc,%esp
80100a53:	53                   	push   %ebx
80100a54:	e8 db 0c 00 00       	call   80101734 <iunlockput>
  end_op();
80100a59:	e8 8f 1e 00 00       	call   801028ed <end_op>
  sz = PGROUNDUP(sz);
80100a5e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE, curproc->pid)) == 0) // revise
80100a69:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a6f:	ff 71 10             	pushl  0x10(%ecx)
80100a72:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a78:	52                   	push   %edx
80100a79:	50                   	push   %eax
80100a7a:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a80:	e8 44 57 00 00       	call   801061c9 <allocuvm>
80100a85:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a8b:	83 c4 20             	add    $0x20,%esp
80100a8e:	85 c0                	test   %eax,%eax
80100a90:	75 24                	jne    80100ab6 <exec+0x1e4>
  ip = 0;
80100a92:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a97:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a9d:	85 c0                	test   %eax,%eax
80100a9f:	0f 84 7f fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100aa5:	83 ec 0c             	sub    $0xc,%esp
80100aa8:	50                   	push   %eax
80100aa9:	e8 0e 58 00 00       	call   801062bc <freevm>
80100aae:	83 c4 10             	add    $0x10,%esp
80100ab1:	e9 6e fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ab6:	89 c7                	mov    %eax,%edi
80100ab8:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100abe:	83 ec 08             	sub    $0x8,%esp
80100ac1:	50                   	push   %eax
80100ac2:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100ac8:	e8 ec 58 00 00       	call   801063b9 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100acd:	83 c4 10             	add    $0x10,%esp
80100ad0:	be 00 00 00 00       	mov    $0x0,%esi
80100ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad8:	8d 1c b0             	lea    (%eax,%esi,4),%ebx
80100adb:	8b 03                	mov    (%ebx),%eax
80100add:	85 c0                	test   %eax,%eax
80100adf:	74 4d                	je     80100b2e <exec+0x25c>
    if(argc >= MAXARG)
80100ae1:	83 fe 1f             	cmp    $0x1f,%esi
80100ae4:	0f 87 0d 01 00 00    	ja     80100bf7 <exec+0x325>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100aea:	83 ec 0c             	sub    $0xc,%esp
80100aed:	50                   	push   %eax
80100aee:	e8 cb 33 00 00       	call   80103ebe <strlen>
80100af3:	29 c7                	sub    %eax,%edi
80100af5:	83 ef 01             	sub    $0x1,%edi
80100af8:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100afb:	83 c4 04             	add    $0x4,%esp
80100afe:	ff 33                	pushl  (%ebx)
80100b00:	e8 b9 33 00 00       	call   80103ebe <strlen>
80100b05:	83 c0 01             	add    $0x1,%eax
80100b08:	50                   	push   %eax
80100b09:	ff 33                	pushl  (%ebx)
80100b0b:	57                   	push   %edi
80100b0c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b12:	e8 fd 59 00 00       	call   80106514 <copyout>
80100b17:	83 c4 20             	add    $0x20,%esp
80100b1a:	85 c0                	test   %eax,%eax
80100b1c:	0f 88 df 00 00 00    	js     80100c01 <exec+0x32f>
    ustack[3+argc] = sp;
80100b22:	89 bc b5 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%esi,4)
  for(argc = 0; argv[argc]; argc++) {
80100b29:	83 c6 01             	add    $0x1,%esi
80100b2c:	eb a7                	jmp    80100ad5 <exec+0x203>
  ustack[3+argc] = 0;
80100b2e:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80100b35:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b39:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b40:	ff ff ff 
  ustack[1] = argc;
80100b43:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b49:	8d 04 b5 04 00 00 00 	lea    0x4(,%esi,4),%eax
80100b50:	89 f9                	mov    %edi,%ecx
80100b52:	29 c1                	sub    %eax,%ecx
80100b54:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b5a:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
80100b61:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b63:	50                   	push   %eax
80100b64:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b6a:	50                   	push   %eax
80100b6b:	57                   	push   %edi
80100b6c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b72:	e8 9d 59 00 00       	call   80106514 <copyout>
80100b77:	83 c4 10             	add    $0x10,%esp
80100b7a:	85 c0                	test   %eax,%eax
80100b7c:	0f 88 89 00 00 00    	js     80100c0b <exec+0x339>
  for(last=s=path; *s; s++)
80100b82:	8b 55 08             	mov    0x8(%ebp),%edx
80100b85:	89 d0                	mov    %edx,%eax
80100b87:	eb 03                	jmp    80100b8c <exec+0x2ba>
80100b89:	83 c0 01             	add    $0x1,%eax
80100b8c:	0f b6 08             	movzbl (%eax),%ecx
80100b8f:	84 c9                	test   %cl,%cl
80100b91:	74 0a                	je     80100b9d <exec+0x2cb>
    if(*s == '/')
80100b93:	80 f9 2f             	cmp    $0x2f,%cl
80100b96:	75 f1                	jne    80100b89 <exec+0x2b7>
      last = s+1;
80100b98:	8d 50 01             	lea    0x1(%eax),%edx
80100b9b:	eb ec                	jmp    80100b89 <exec+0x2b7>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b9d:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100ba3:	89 f0                	mov    %esi,%eax
80100ba5:	83 c0 6c             	add    $0x6c,%eax
80100ba8:	83 ec 04             	sub    $0x4,%esp
80100bab:	6a 10                	push   $0x10
80100bad:	52                   	push   %edx
80100bae:	50                   	push   %eax
80100baf:	e8 cf 32 00 00       	call   80103e83 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bb4:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bb7:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bbd:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bc0:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bc6:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bd1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bd4:	8b 46 18             	mov    0x18(%esi),%eax
80100bd7:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bda:	89 34 24             	mov    %esi,(%esp)
80100bdd:	e8 2f 53 00 00       	call   80105f11 <switchuvm>
  freevm(oldpgdir);
80100be2:	89 1c 24             	mov    %ebx,(%esp)
80100be5:	e8 d2 56 00 00       	call   801062bc <freevm>
  return 0;
80100bea:	83 c4 10             	add    $0x10,%esp
80100bed:	b8 00 00 00 00       	mov    $0x0,%eax
80100bf2:	e9 4b fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100bf7:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfc:	e9 96 fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c01:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c06:	e9 8c fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c10:	e9 82 fe ff ff       	jmp    80100a97 <exec+0x1c5>
  return -1;
80100c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c1a:	e9 23 fd ff ff       	jmp    80100942 <exec+0x70>

80100c1f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c1f:	55                   	push   %ebp
80100c20:	89 e5                	mov    %esp,%ebp
80100c22:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c25:	68 2d 66 10 80       	push   $0x8010662d
80100c2a:	68 e0 ef 12 80       	push   $0x8012efe0
80100c2f:	e8 00 2f 00 00       	call   80103b34 <initlock>
}
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	c9                   	leave  
80100c38:	c3                   	ret    

80100c39 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c39:	55                   	push   %ebp
80100c3a:	89 e5                	mov    %esp,%ebp
80100c3c:	53                   	push   %ebx
80100c3d:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c40:	68 e0 ef 12 80       	push   $0x8012efe0
80100c45:	e8 26 30 00 00       	call   80103c70 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c4a:	83 c4 10             	add    $0x10,%esp
80100c4d:	bb 14 f0 12 80       	mov    $0x8012f014,%ebx
80100c52:	81 fb 74 f9 12 80    	cmp    $0x8012f974,%ebx
80100c58:	73 29                	jae    80100c83 <filealloc+0x4a>
    if(f->ref == 0){
80100c5a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c5e:	74 05                	je     80100c65 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c60:	83 c3 18             	add    $0x18,%ebx
80100c63:	eb ed                	jmp    80100c52 <filealloc+0x19>
      f->ref = 1;
80100c65:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c6c:	83 ec 0c             	sub    $0xc,%esp
80100c6f:	68 e0 ef 12 80       	push   $0x8012efe0
80100c74:	e8 5c 30 00 00       	call   80103cd5 <release>
      return f;
80100c79:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c7c:	89 d8                	mov    %ebx,%eax
80100c7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c81:	c9                   	leave  
80100c82:	c3                   	ret    
  release(&ftable.lock);
80100c83:	83 ec 0c             	sub    $0xc,%esp
80100c86:	68 e0 ef 12 80       	push   $0x8012efe0
80100c8b:	e8 45 30 00 00       	call   80103cd5 <release>
  return 0;
80100c90:	83 c4 10             	add    $0x10,%esp
80100c93:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c98:	eb e2                	jmp    80100c7c <filealloc+0x43>

80100c9a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c9a:	55                   	push   %ebp
80100c9b:	89 e5                	mov    %esp,%ebp
80100c9d:	53                   	push   %ebx
80100c9e:	83 ec 10             	sub    $0x10,%esp
80100ca1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100ca4:	68 e0 ef 12 80       	push   $0x8012efe0
80100ca9:	e8 c2 2f 00 00       	call   80103c70 <acquire>
  if(f->ref < 1)
80100cae:	8b 43 04             	mov    0x4(%ebx),%eax
80100cb1:	83 c4 10             	add    $0x10,%esp
80100cb4:	85 c0                	test   %eax,%eax
80100cb6:	7e 1a                	jle    80100cd2 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cb8:	83 c0 01             	add    $0x1,%eax
80100cbb:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cbe:	83 ec 0c             	sub    $0xc,%esp
80100cc1:	68 e0 ef 12 80       	push   $0x8012efe0
80100cc6:	e8 0a 30 00 00       	call   80103cd5 <release>
  return f;
}
80100ccb:	89 d8                	mov    %ebx,%eax
80100ccd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cd0:	c9                   	leave  
80100cd1:	c3                   	ret    
    panic("filedup");
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	68 34 66 10 80       	push   $0x80106634
80100cda:	e8 69 f6 ff ff       	call   80100348 <panic>

80100cdf <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cdf:	55                   	push   %ebp
80100ce0:	89 e5                	mov    %esp,%ebp
80100ce2:	53                   	push   %ebx
80100ce3:	83 ec 30             	sub    $0x30,%esp
80100ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100ce9:	68 e0 ef 12 80       	push   $0x8012efe0
80100cee:	e8 7d 2f 00 00       	call   80103c70 <acquire>
  if(f->ref < 1)
80100cf3:	8b 43 04             	mov    0x4(%ebx),%eax
80100cf6:	83 c4 10             	add    $0x10,%esp
80100cf9:	85 c0                	test   %eax,%eax
80100cfb:	7e 1f                	jle    80100d1c <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cfd:	83 e8 01             	sub    $0x1,%eax
80100d00:	89 43 04             	mov    %eax,0x4(%ebx)
80100d03:	85 c0                	test   %eax,%eax
80100d05:	7e 22                	jle    80100d29 <fileclose+0x4a>
    release(&ftable.lock);
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	68 e0 ef 12 80       	push   $0x8012efe0
80100d0f:	e8 c1 2f 00 00       	call   80103cd5 <release>
    return;
80100d14:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d1a:	c9                   	leave  
80100d1b:	c3                   	ret    
    panic("fileclose");
80100d1c:	83 ec 0c             	sub    $0xc,%esp
80100d1f:	68 3c 66 10 80       	push   $0x8010663c
80100d24:	e8 1f f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d29:	8b 03                	mov    (%ebx),%eax
80100d2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d2e:	8b 43 08             	mov    0x8(%ebx),%eax
80100d31:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d34:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d3a:	8b 43 10             	mov    0x10(%ebx),%eax
80100d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d40:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d4d:	83 ec 0c             	sub    $0xc,%esp
80100d50:	68 e0 ef 12 80       	push   $0x8012efe0
80100d55:	e8 7b 2f 00 00       	call   80103cd5 <release>
  if(ff.type == FD_PIPE)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	83 c4 10             	add    $0x10,%esp
80100d60:	83 f8 01             	cmp    $0x1,%eax
80100d63:	74 1f                	je     80100d84 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d65:	83 f8 02             	cmp    $0x2,%eax
80100d68:	75 ad                	jne    80100d17 <fileclose+0x38>
    begin_op();
80100d6a:	e8 04 1b 00 00       	call   80102873 <begin_op>
    iput(ff.ip);
80100d6f:	83 ec 0c             	sub    $0xc,%esp
80100d72:	ff 75 f0             	pushl  -0x10(%ebp)
80100d75:	e8 1a 09 00 00       	call   80101694 <iput>
    end_op();
80100d7a:	e8 6e 1b 00 00       	call   801028ed <end_op>
80100d7f:	83 c4 10             	add    $0x10,%esp
80100d82:	eb 93                	jmp    80100d17 <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d84:	83 ec 08             	sub    $0x8,%esp
80100d87:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d8b:	50                   	push   %eax
80100d8c:	ff 75 ec             	pushl  -0x14(%ebp)
80100d8f:	e8 60 21 00 00       	call   80102ef4 <pipeclose>
80100d94:	83 c4 10             	add    $0x10,%esp
80100d97:	e9 7b ff ff ff       	jmp    80100d17 <fileclose+0x38>

80100d9c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d9c:	55                   	push   %ebp
80100d9d:	89 e5                	mov    %esp,%ebp
80100d9f:	53                   	push   %ebx
80100da0:	83 ec 04             	sub    $0x4,%esp
80100da3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100da6:	83 3b 02             	cmpl   $0x2,(%ebx)
80100da9:	75 31                	jne    80100ddc <filestat+0x40>
    ilock(f->ip);
80100dab:	83 ec 0c             	sub    $0xc,%esp
80100dae:	ff 73 10             	pushl  0x10(%ebx)
80100db1:	e8 d7 07 00 00       	call   8010158d <ilock>
    stati(f->ip, st);
80100db6:	83 c4 08             	add    $0x8,%esp
80100db9:	ff 75 0c             	pushl  0xc(%ebp)
80100dbc:	ff 73 10             	pushl  0x10(%ebx)
80100dbf:	e8 90 09 00 00       	call   80101754 <stati>
    iunlock(f->ip);
80100dc4:	83 c4 04             	add    $0x4,%esp
80100dc7:	ff 73 10             	pushl  0x10(%ebx)
80100dca:	e8 80 08 00 00       	call   8010164f <iunlock>
    return 0;
80100dcf:	83 c4 10             	add    $0x10,%esp
80100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dda:	c9                   	leave  
80100ddb:	c3                   	ret    
  return -1;
80100ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100de1:	eb f4                	jmp    80100dd7 <filestat+0x3b>

80100de3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100de3:	55                   	push   %ebp
80100de4:	89 e5                	mov    %esp,%ebp
80100de6:	56                   	push   %esi
80100de7:	53                   	push   %ebx
80100de8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100deb:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100def:	74 70                	je     80100e61 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100df1:	8b 03                	mov    (%ebx),%eax
80100df3:	83 f8 01             	cmp    $0x1,%eax
80100df6:	74 44                	je     80100e3c <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100df8:	83 f8 02             	cmp    $0x2,%eax
80100dfb:	75 57                	jne    80100e54 <fileread+0x71>
    ilock(f->ip);
80100dfd:	83 ec 0c             	sub    $0xc,%esp
80100e00:	ff 73 10             	pushl  0x10(%ebx)
80100e03:	e8 85 07 00 00       	call   8010158d <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e08:	ff 75 10             	pushl  0x10(%ebp)
80100e0b:	ff 73 14             	pushl  0x14(%ebx)
80100e0e:	ff 75 0c             	pushl  0xc(%ebp)
80100e11:	ff 73 10             	pushl  0x10(%ebx)
80100e14:	e8 66 09 00 00       	call   8010177f <readi>
80100e19:	89 c6                	mov    %eax,%esi
80100e1b:	83 c4 20             	add    $0x20,%esp
80100e1e:	85 c0                	test   %eax,%eax
80100e20:	7e 03                	jle    80100e25 <fileread+0x42>
      f->off += r;
80100e22:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e25:	83 ec 0c             	sub    $0xc,%esp
80100e28:	ff 73 10             	pushl  0x10(%ebx)
80100e2b:	e8 1f 08 00 00       	call   8010164f <iunlock>
    return r;
80100e30:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e33:	89 f0                	mov    %esi,%eax
80100e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e38:	5b                   	pop    %ebx
80100e39:	5e                   	pop    %esi
80100e3a:	5d                   	pop    %ebp
80100e3b:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e3c:	83 ec 04             	sub    $0x4,%esp
80100e3f:	ff 75 10             	pushl  0x10(%ebp)
80100e42:	ff 75 0c             	pushl  0xc(%ebp)
80100e45:	ff 73 0c             	pushl  0xc(%ebx)
80100e48:	e8 ff 21 00 00       	call   8010304c <piperead>
80100e4d:	89 c6                	mov    %eax,%esi
80100e4f:	83 c4 10             	add    $0x10,%esp
80100e52:	eb df                	jmp    80100e33 <fileread+0x50>
  panic("fileread");
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	68 46 66 10 80       	push   $0x80106646
80100e5c:	e8 e7 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e61:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e66:	eb cb                	jmp    80100e33 <fileread+0x50>

80100e68 <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e68:	55                   	push   %ebp
80100e69:	89 e5                	mov    %esp,%ebp
80100e6b:	57                   	push   %edi
80100e6c:	56                   	push   %esi
80100e6d:	53                   	push   %ebx
80100e6e:	83 ec 1c             	sub    $0x1c,%esp
80100e71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e74:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e78:	0f 84 c5 00 00 00    	je     80100f43 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e7e:	8b 03                	mov    (%ebx),%eax
80100e80:	83 f8 01             	cmp    $0x1,%eax
80100e83:	74 10                	je     80100e95 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e85:	83 f8 02             	cmp    $0x2,%eax
80100e88:	0f 85 a8 00 00 00    	jne    80100f36 <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e8e:	bf 00 00 00 00       	mov    $0x0,%edi
80100e93:	eb 67                	jmp    80100efc <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e95:	83 ec 04             	sub    $0x4,%esp
80100e98:	ff 75 10             	pushl  0x10(%ebp)
80100e9b:	ff 75 0c             	pushl  0xc(%ebp)
80100e9e:	ff 73 0c             	pushl  0xc(%ebx)
80100ea1:	e8 da 20 00 00       	call   80102f80 <pipewrite>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	e9 80 00 00 00       	jmp    80100f2e <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100eae:	e8 c0 19 00 00       	call   80102873 <begin_op>
      ilock(f->ip);
80100eb3:	83 ec 0c             	sub    $0xc,%esp
80100eb6:	ff 73 10             	pushl  0x10(%ebx)
80100eb9:	e8 cf 06 00 00       	call   8010158d <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ebe:	89 f8                	mov    %edi,%eax
80100ec0:	03 45 0c             	add    0xc(%ebp),%eax
80100ec3:	ff 75 e4             	pushl  -0x1c(%ebp)
80100ec6:	ff 73 14             	pushl  0x14(%ebx)
80100ec9:	50                   	push   %eax
80100eca:	ff 73 10             	pushl  0x10(%ebx)
80100ecd:	e8 aa 09 00 00       	call   8010187c <writei>
80100ed2:	89 c6                	mov    %eax,%esi
80100ed4:	83 c4 20             	add    $0x20,%esp
80100ed7:	85 c0                	test   %eax,%eax
80100ed9:	7e 03                	jle    80100ede <filewrite+0x76>
        f->off += r;
80100edb:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ede:	83 ec 0c             	sub    $0xc,%esp
80100ee1:	ff 73 10             	pushl  0x10(%ebx)
80100ee4:	e8 66 07 00 00       	call   8010164f <iunlock>
      end_op();
80100ee9:	e8 ff 19 00 00       	call   801028ed <end_op>

      if(r < 0)
80100eee:	83 c4 10             	add    $0x10,%esp
80100ef1:	85 f6                	test   %esi,%esi
80100ef3:	78 31                	js     80100f26 <filewrite+0xbe>
        break;
      if(r != n1)
80100ef5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100ef8:	75 1f                	jne    80100f19 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100efa:	01 f7                	add    %esi,%edi
    while(i < n){
80100efc:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100eff:	7d 25                	jge    80100f26 <filewrite+0xbe>
      int n1 = n - i;
80100f01:	8b 45 10             	mov    0x10(%ebp),%eax
80100f04:	29 f8                	sub    %edi,%eax
80100f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100f09:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f0e:	7e 9e                	jle    80100eae <filewrite+0x46>
        n1 = max;
80100f10:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f17:	eb 95                	jmp    80100eae <filewrite+0x46>
        panic("short filewrite");
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	68 4f 66 10 80       	push   $0x8010664f
80100f21:	e8 22 f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f26:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f29:	75 1f                	jne    80100f4a <filewrite+0xe2>
80100f2b:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f31:	5b                   	pop    %ebx
80100f32:	5e                   	pop    %esi
80100f33:	5f                   	pop    %edi
80100f34:	5d                   	pop    %ebp
80100f35:	c3                   	ret    
  panic("filewrite");
80100f36:	83 ec 0c             	sub    $0xc,%esp
80100f39:	68 55 66 10 80       	push   $0x80106655
80100f3e:	e8 05 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f48:	eb e4                	jmp    80100f2e <filewrite+0xc6>
    return i == n ? n : -1;
80100f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f4f:	eb dd                	jmp    80100f2e <filewrite+0xc6>

80100f51 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f51:	55                   	push   %ebp
80100f52:	89 e5                	mov    %esp,%ebp
80100f54:	57                   	push   %edi
80100f55:	56                   	push   %esi
80100f56:	53                   	push   %ebx
80100f57:	83 ec 0c             	sub    $0xc,%esp
80100f5a:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f5c:	eb 03                	jmp    80100f61 <skipelem+0x10>
    path++;
80100f5e:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f61:	0f b6 10             	movzbl (%eax),%edx
80100f64:	80 fa 2f             	cmp    $0x2f,%dl
80100f67:	74 f5                	je     80100f5e <skipelem+0xd>
  if(*path == 0)
80100f69:	84 d2                	test   %dl,%dl
80100f6b:	74 59                	je     80100fc6 <skipelem+0x75>
80100f6d:	89 c3                	mov    %eax,%ebx
80100f6f:	eb 03                	jmp    80100f74 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f71:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f74:	0f b6 13             	movzbl (%ebx),%edx
80100f77:	80 fa 2f             	cmp    $0x2f,%dl
80100f7a:	0f 95 c1             	setne  %cl
80100f7d:	84 d2                	test   %dl,%dl
80100f7f:	0f 95 c2             	setne  %dl
80100f82:	84 d1                	test   %dl,%cl
80100f84:	75 eb                	jne    80100f71 <skipelem+0x20>
  len = path - s;
80100f86:	89 de                	mov    %ebx,%esi
80100f88:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f8a:	83 fe 0d             	cmp    $0xd,%esi
80100f8d:	7e 11                	jle    80100fa0 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f8f:	83 ec 04             	sub    $0x4,%esp
80100f92:	6a 0e                	push   $0xe
80100f94:	50                   	push   %eax
80100f95:	57                   	push   %edi
80100f96:	e8 fc 2d 00 00       	call   80103d97 <memmove>
80100f9b:	83 c4 10             	add    $0x10,%esp
80100f9e:	eb 17                	jmp    80100fb7 <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fa0:	83 ec 04             	sub    $0x4,%esp
80100fa3:	56                   	push   %esi
80100fa4:	50                   	push   %eax
80100fa5:	57                   	push   %edi
80100fa6:	e8 ec 2d 00 00       	call   80103d97 <memmove>
    name[len] = 0;
80100fab:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100faf:	83 c4 10             	add    $0x10,%esp
80100fb2:	eb 03                	jmp    80100fb7 <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fb4:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fb7:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fba:	74 f8                	je     80100fb4 <skipelem+0x63>
  return path;
}
80100fbc:	89 d8                	mov    %ebx,%eax
80100fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc1:	5b                   	pop    %ebx
80100fc2:	5e                   	pop    %esi
80100fc3:	5f                   	pop    %edi
80100fc4:	5d                   	pop    %ebp
80100fc5:	c3                   	ret    
    return 0;
80100fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fcb:	eb ef                	jmp    80100fbc <skipelem+0x6b>

80100fcd <bzero>:
{
80100fcd:	55                   	push   %ebp
80100fce:	89 e5                	mov    %esp,%ebp
80100fd0:	53                   	push   %ebx
80100fd1:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fd4:	52                   	push   %edx
80100fd5:	50                   	push   %eax
80100fd6:	e8 91 f1 ff ff       	call   8010016c <bread>
80100fdb:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fdd:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fe0:	83 c4 0c             	add    $0xc,%esp
80100fe3:	68 00 02 00 00       	push   $0x200
80100fe8:	6a 00                	push   $0x0
80100fea:	50                   	push   %eax
80100feb:	e8 2c 2d 00 00       	call   80103d1c <memset>
  log_write(bp);
80100ff0:	89 1c 24             	mov    %ebx,(%esp)
80100ff3:	e8 a4 19 00 00       	call   8010299c <log_write>
  brelse(bp);
80100ff8:	89 1c 24             	mov    %ebx,(%esp)
80100ffb:	e8 d5 f1 ff ff       	call   801001d5 <brelse>
}
80101000:	83 c4 10             	add    $0x10,%esp
80101003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101006:	c9                   	leave  
80101007:	c3                   	ret    

80101008 <balloc>:
{
80101008:	55                   	push   %ebp
80101009:	89 e5                	mov    %esp,%ebp
8010100b:	57                   	push   %edi
8010100c:	56                   	push   %esi
8010100d:	53                   	push   %ebx
8010100e:	83 ec 1c             	sub    $0x1c,%esp
80101011:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101014:	be 00 00 00 00       	mov    $0x0,%esi
80101019:	eb 14                	jmp    8010102f <balloc+0x27>
    brelse(bp);
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101021:	e8 af f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101026:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010102c:	83 c4 10             	add    $0x10,%esp
8010102f:	39 35 e0 f9 12 80    	cmp    %esi,0x8012f9e0
80101035:	76 75                	jbe    801010ac <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
80101037:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
8010103d:	85 f6                	test   %esi,%esi
8010103f:	0f 49 c6             	cmovns %esi,%eax
80101042:	c1 f8 0c             	sar    $0xc,%eax
80101045:	03 05 f8 f9 12 80    	add    0x8012f9f8,%eax
8010104b:	83 ec 08             	sub    $0x8,%esp
8010104e:	50                   	push   %eax
8010104f:	ff 75 d8             	pushl  -0x28(%ebp)
80101052:	e8 15 f1 ff ff       	call   8010016c <bread>
80101057:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010105a:	83 c4 10             	add    $0x10,%esp
8010105d:	b8 00 00 00 00       	mov    $0x0,%eax
80101062:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80101067:	7f b2                	jg     8010101b <balloc+0x13>
80101069:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
8010106c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
8010106f:	3b 1d e0 f9 12 80    	cmp    0x8012f9e0,%ebx
80101075:	73 a4                	jae    8010101b <balloc+0x13>
      m = 1 << (bi % 8);
80101077:	99                   	cltd   
80101078:	c1 ea 1d             	shr    $0x1d,%edx
8010107b:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010107e:	83 e1 07             	and    $0x7,%ecx
80101081:	29 d1                	sub    %edx,%ecx
80101083:	ba 01 00 00 00       	mov    $0x1,%edx
80101088:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010108a:	8d 48 07             	lea    0x7(%eax),%ecx
8010108d:	85 c0                	test   %eax,%eax
8010108f:	0f 49 c8             	cmovns %eax,%ecx
80101092:	c1 f9 03             	sar    $0x3,%ecx
80101095:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80101098:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010109b:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
801010a0:	0f b6 f9             	movzbl %cl,%edi
801010a3:	85 d7                	test   %edx,%edi
801010a5:	74 12                	je     801010b9 <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010a7:	83 c0 01             	add    $0x1,%eax
801010aa:	eb b6                	jmp    80101062 <balloc+0x5a>
  panic("balloc: out of blocks");
801010ac:	83 ec 0c             	sub    $0xc,%esp
801010af:	68 5f 66 10 80       	push   $0x8010665f
801010b4:	e8 8f f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010b9:	09 ca                	or     %ecx,%edx
801010bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010be:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010c1:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	89 c6                	mov    %eax,%esi
801010ca:	50                   	push   %eax
801010cb:	e8 cc 18 00 00       	call   8010299c <log_write>
        brelse(bp);
801010d0:	89 34 24             	mov    %esi,(%esp)
801010d3:	e8 fd f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010d8:	89 da                	mov    %ebx,%edx
801010da:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010dd:	e8 eb fe ff ff       	call   80100fcd <bzero>
}
801010e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010e8:	5b                   	pop    %ebx
801010e9:	5e                   	pop    %esi
801010ea:	5f                   	pop    %edi
801010eb:	5d                   	pop    %ebp
801010ec:	c3                   	ret    

801010ed <bmap>:
{
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	57                   	push   %edi
801010f1:	56                   	push   %esi
801010f2:	53                   	push   %ebx
801010f3:	83 ec 1c             	sub    $0x1c,%esp
801010f6:	89 c6                	mov    %eax,%esi
801010f8:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801010fa:	83 fa 0b             	cmp    $0xb,%edx
801010fd:	77 17                	ja     80101116 <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
801010ff:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
80101103:	85 db                	test   %ebx,%ebx
80101105:	75 4a                	jne    80101151 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101107:	8b 00                	mov    (%eax),%eax
80101109:	e8 fa fe ff ff       	call   80101008 <balloc>
8010110e:	89 c3                	mov    %eax,%ebx
80101110:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101114:	eb 3b                	jmp    80101151 <bmap+0x64>
  bn -= NDIRECT;
80101116:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
80101119:	83 fb 7f             	cmp    $0x7f,%ebx
8010111c:	77 68                	ja     80101186 <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
8010111e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101124:	85 c0                	test   %eax,%eax
80101126:	74 33                	je     8010115b <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101128:	83 ec 08             	sub    $0x8,%esp
8010112b:	50                   	push   %eax
8010112c:	ff 36                	pushl  (%esi)
8010112e:	e8 39 f0 ff ff       	call   8010016c <bread>
80101133:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101135:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
80101139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010113c:	8b 18                	mov    (%eax),%ebx
8010113e:	83 c4 10             	add    $0x10,%esp
80101141:	85 db                	test   %ebx,%ebx
80101143:	74 25                	je     8010116a <bmap+0x7d>
    brelse(bp);
80101145:	83 ec 0c             	sub    $0xc,%esp
80101148:	57                   	push   %edi
80101149:	e8 87 f0 ff ff       	call   801001d5 <brelse>
    return addr;
8010114e:	83 c4 10             	add    $0x10,%esp
}
80101151:	89 d8                	mov    %ebx,%eax
80101153:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101156:	5b                   	pop    %ebx
80101157:	5e                   	pop    %esi
80101158:	5f                   	pop    %edi
80101159:	5d                   	pop    %ebp
8010115a:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010115b:	8b 06                	mov    (%esi),%eax
8010115d:	e8 a6 fe ff ff       	call   80101008 <balloc>
80101162:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101168:	eb be                	jmp    80101128 <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
8010116a:	8b 06                	mov    (%esi),%eax
8010116c:	e8 97 fe ff ff       	call   80101008 <balloc>
80101171:	89 c3                	mov    %eax,%ebx
80101173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101176:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
80101178:	83 ec 0c             	sub    $0xc,%esp
8010117b:	57                   	push   %edi
8010117c:	e8 1b 18 00 00       	call   8010299c <log_write>
80101181:	83 c4 10             	add    $0x10,%esp
80101184:	eb bf                	jmp    80101145 <bmap+0x58>
  panic("bmap: out of range");
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	68 75 66 10 80       	push   $0x80106675
8010118e:	e8 b5 f1 ff ff       	call   80100348 <panic>

80101193 <iget>:
{
80101193:	55                   	push   %ebp
80101194:	89 e5                	mov    %esp,%ebp
80101196:	57                   	push   %edi
80101197:	56                   	push   %esi
80101198:	53                   	push   %ebx
80101199:	83 ec 28             	sub    $0x28,%esp
8010119c:	89 c7                	mov    %eax,%edi
8010119e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801011a1:	68 00 fa 12 80       	push   $0x8012fa00
801011a6:	e8 c5 2a 00 00       	call   80103c70 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011ab:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011ae:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b3:	bb 34 fa 12 80       	mov    $0x8012fa34,%ebx
801011b8:	eb 0a                	jmp    801011c4 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ba:	85 f6                	test   %esi,%esi
801011bc:	74 3b                	je     801011f9 <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011be:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011c4:	81 fb 54 16 13 80    	cmp    $0x80131654,%ebx
801011ca:	73 35                	jae    80101201 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011cc:	8b 43 08             	mov    0x8(%ebx),%eax
801011cf:	85 c0                	test   %eax,%eax
801011d1:	7e e7                	jle    801011ba <iget+0x27>
801011d3:	39 3b                	cmp    %edi,(%ebx)
801011d5:	75 e3                	jne    801011ba <iget+0x27>
801011d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011da:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011dd:	75 db                	jne    801011ba <iget+0x27>
      ip->ref++;
801011df:	83 c0 01             	add    $0x1,%eax
801011e2:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011e5:	83 ec 0c             	sub    $0xc,%esp
801011e8:	68 00 fa 12 80       	push   $0x8012fa00
801011ed:	e8 e3 2a 00 00       	call   80103cd5 <release>
      return ip;
801011f2:	83 c4 10             	add    $0x10,%esp
801011f5:	89 de                	mov    %ebx,%esi
801011f7:	eb 32                	jmp    8010122b <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011f9:	85 c0                	test   %eax,%eax
801011fb:	75 c1                	jne    801011be <iget+0x2b>
      empty = ip;
801011fd:	89 de                	mov    %ebx,%esi
801011ff:	eb bd                	jmp    801011be <iget+0x2b>
  if(empty == 0)
80101201:	85 f6                	test   %esi,%esi
80101203:	74 30                	je     80101235 <iget+0xa2>
  ip->dev = dev;
80101205:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010120a:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
8010120d:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101214:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010121b:	83 ec 0c             	sub    $0xc,%esp
8010121e:	68 00 fa 12 80       	push   $0x8012fa00
80101223:	e8 ad 2a 00 00       	call   80103cd5 <release>
  return ip;
80101228:	83 c4 10             	add    $0x10,%esp
}
8010122b:	89 f0                	mov    %esi,%eax
8010122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101230:	5b                   	pop    %ebx
80101231:	5e                   	pop    %esi
80101232:	5f                   	pop    %edi
80101233:	5d                   	pop    %ebp
80101234:	c3                   	ret    
    panic("iget: no inodes");
80101235:	83 ec 0c             	sub    $0xc,%esp
80101238:	68 88 66 10 80       	push   $0x80106688
8010123d:	e8 06 f1 ff ff       	call   80100348 <panic>

80101242 <readsb>:
{
80101242:	55                   	push   %ebp
80101243:	89 e5                	mov    %esp,%ebp
80101245:	53                   	push   %ebx
80101246:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
80101249:	6a 01                	push   $0x1
8010124b:	ff 75 08             	pushl  0x8(%ebp)
8010124e:	e8 19 ef ff ff       	call   8010016c <bread>
80101253:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101255:	8d 40 5c             	lea    0x5c(%eax),%eax
80101258:	83 c4 0c             	add    $0xc,%esp
8010125b:	6a 1c                	push   $0x1c
8010125d:	50                   	push   %eax
8010125e:	ff 75 0c             	pushl  0xc(%ebp)
80101261:	e8 31 2b 00 00       	call   80103d97 <memmove>
  brelse(bp);
80101266:	89 1c 24             	mov    %ebx,(%esp)
80101269:	e8 67 ef ff ff       	call   801001d5 <brelse>
}
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101274:	c9                   	leave  
80101275:	c3                   	ret    

80101276 <bfree>:
{
80101276:	55                   	push   %ebp
80101277:	89 e5                	mov    %esp,%ebp
80101279:	56                   	push   %esi
8010127a:	53                   	push   %ebx
8010127b:	89 c6                	mov    %eax,%esi
8010127d:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
8010127f:	83 ec 08             	sub    $0x8,%esp
80101282:	68 e0 f9 12 80       	push   $0x8012f9e0
80101287:	50                   	push   %eax
80101288:	e8 b5 ff ff ff       	call   80101242 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010128d:	89 d8                	mov    %ebx,%eax
8010128f:	c1 e8 0c             	shr    $0xc,%eax
80101292:	03 05 f8 f9 12 80    	add    0x8012f9f8,%eax
80101298:	83 c4 08             	add    $0x8,%esp
8010129b:	50                   	push   %eax
8010129c:	56                   	push   %esi
8010129d:	e8 ca ee ff ff       	call   8010016c <bread>
801012a2:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801012a4:	89 d9                	mov    %ebx,%ecx
801012a6:	83 e1 07             	and    $0x7,%ecx
801012a9:	b8 01 00 00 00       	mov    $0x1,%eax
801012ae:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012b0:	83 c4 10             	add    $0x10,%esp
801012b3:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012b9:	c1 fb 03             	sar    $0x3,%ebx
801012bc:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012c1:	0f b6 ca             	movzbl %dl,%ecx
801012c4:	85 c1                	test   %eax,%ecx
801012c6:	74 23                	je     801012eb <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012c8:	f7 d0                	not    %eax
801012ca:	21 d0                	and    %edx,%eax
801012cc:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012d0:	83 ec 0c             	sub    $0xc,%esp
801012d3:	56                   	push   %esi
801012d4:	e8 c3 16 00 00       	call   8010299c <log_write>
  brelse(bp);
801012d9:	89 34 24             	mov    %esi,(%esp)
801012dc:	e8 f4 ee ff ff       	call   801001d5 <brelse>
}
801012e1:	83 c4 10             	add    $0x10,%esp
801012e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012e7:	5b                   	pop    %ebx
801012e8:	5e                   	pop    %esi
801012e9:	5d                   	pop    %ebp
801012ea:	c3                   	ret    
    panic("freeing free block");
801012eb:	83 ec 0c             	sub    $0xc,%esp
801012ee:	68 98 66 10 80       	push   $0x80106698
801012f3:	e8 50 f0 ff ff       	call   80100348 <panic>

801012f8 <iinit>:
{
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	53                   	push   %ebx
801012fc:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012ff:	68 ab 66 10 80       	push   $0x801066ab
80101304:	68 00 fa 12 80       	push   $0x8012fa00
80101309:	e8 26 28 00 00       	call   80103b34 <initlock>
  for(i = 0; i < NINODE; i++) {
8010130e:	83 c4 10             	add    $0x10,%esp
80101311:	bb 00 00 00 00       	mov    $0x0,%ebx
80101316:	eb 21                	jmp    80101339 <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
80101318:	83 ec 08             	sub    $0x8,%esp
8010131b:	68 b2 66 10 80       	push   $0x801066b2
80101320:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101323:	89 d0                	mov    %edx,%eax
80101325:	c1 e0 04             	shl    $0x4,%eax
80101328:	05 40 fa 12 80       	add    $0x8012fa40,%eax
8010132d:	50                   	push   %eax
8010132e:	e8 f6 26 00 00       	call   80103a29 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101333:	83 c3 01             	add    $0x1,%ebx
80101336:	83 c4 10             	add    $0x10,%esp
80101339:	83 fb 31             	cmp    $0x31,%ebx
8010133c:	7e da                	jle    80101318 <iinit+0x20>
  readsb(dev, &sb);
8010133e:	83 ec 08             	sub    $0x8,%esp
80101341:	68 e0 f9 12 80       	push   $0x8012f9e0
80101346:	ff 75 08             	pushl  0x8(%ebp)
80101349:	e8 f4 fe ff ff       	call   80101242 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010134e:	ff 35 f8 f9 12 80    	pushl  0x8012f9f8
80101354:	ff 35 f4 f9 12 80    	pushl  0x8012f9f4
8010135a:	ff 35 f0 f9 12 80    	pushl  0x8012f9f0
80101360:	ff 35 ec f9 12 80    	pushl  0x8012f9ec
80101366:	ff 35 e8 f9 12 80    	pushl  0x8012f9e8
8010136c:	ff 35 e4 f9 12 80    	pushl  0x8012f9e4
80101372:	ff 35 e0 f9 12 80    	pushl  0x8012f9e0
80101378:	68 18 67 10 80       	push   $0x80106718
8010137d:	e8 89 f2 ff ff       	call   8010060b <cprintf>
}
80101382:	83 c4 30             	add    $0x30,%esp
80101385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101388:	c9                   	leave  
80101389:	c3                   	ret    

8010138a <ialloc>:
{
8010138a:	55                   	push   %ebp
8010138b:	89 e5                	mov    %esp,%ebp
8010138d:	57                   	push   %edi
8010138e:	56                   	push   %esi
8010138f:	53                   	push   %ebx
80101390:	83 ec 1c             	sub    $0x1c,%esp
80101393:	8b 45 0c             	mov    0xc(%ebp),%eax
80101396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101399:	bb 01 00 00 00       	mov    $0x1,%ebx
8010139e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801013a1:	39 1d e8 f9 12 80    	cmp    %ebx,0x8012f9e8
801013a7:	76 3f                	jbe    801013e8 <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
801013a9:	89 d8                	mov    %ebx,%eax
801013ab:	c1 e8 03             	shr    $0x3,%eax
801013ae:	03 05 f4 f9 12 80    	add    0x8012f9f4,%eax
801013b4:	83 ec 08             	sub    $0x8,%esp
801013b7:	50                   	push   %eax
801013b8:	ff 75 08             	pushl  0x8(%ebp)
801013bb:	e8 ac ed ff ff       	call   8010016c <bread>
801013c0:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013c2:	89 d8                	mov    %ebx,%eax
801013c4:	83 e0 07             	and    $0x7,%eax
801013c7:	c1 e0 06             	shl    $0x6,%eax
801013ca:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013ce:	83 c4 10             	add    $0x10,%esp
801013d1:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013d5:	74 1e                	je     801013f5 <ialloc+0x6b>
    brelse(bp);
801013d7:	83 ec 0c             	sub    $0xc,%esp
801013da:	56                   	push   %esi
801013db:	e8 f5 ed ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013e0:	83 c3 01             	add    $0x1,%ebx
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	eb b6                	jmp    8010139e <ialloc+0x14>
  panic("ialloc: no inodes");
801013e8:	83 ec 0c             	sub    $0xc,%esp
801013eb:	68 b8 66 10 80       	push   $0x801066b8
801013f0:	e8 53 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013f5:	83 ec 04             	sub    $0x4,%esp
801013f8:	6a 40                	push   $0x40
801013fa:	6a 00                	push   $0x0
801013fc:	57                   	push   %edi
801013fd:	e8 1a 29 00 00       	call   80103d1c <memset>
      dip->type = type;
80101402:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101406:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101409:	89 34 24             	mov    %esi,(%esp)
8010140c:	e8 8b 15 00 00       	call   8010299c <log_write>
      brelse(bp);
80101411:	89 34 24             	mov    %esi,(%esp)
80101414:	e8 bc ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
80101419:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010141c:	8b 45 08             	mov    0x8(%ebp),%eax
8010141f:	e8 6f fd ff ff       	call   80101193 <iget>
}
80101424:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101427:	5b                   	pop    %ebx
80101428:	5e                   	pop    %esi
80101429:	5f                   	pop    %edi
8010142a:	5d                   	pop    %ebp
8010142b:	c3                   	ret    

8010142c <iupdate>:
{
8010142c:	55                   	push   %ebp
8010142d:	89 e5                	mov    %esp,%ebp
8010142f:	56                   	push   %esi
80101430:	53                   	push   %ebx
80101431:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101434:	8b 43 04             	mov    0x4(%ebx),%eax
80101437:	c1 e8 03             	shr    $0x3,%eax
8010143a:	03 05 f4 f9 12 80    	add    0x8012f9f4,%eax
80101440:	83 ec 08             	sub    $0x8,%esp
80101443:	50                   	push   %eax
80101444:	ff 33                	pushl  (%ebx)
80101446:	e8 21 ed ff ff       	call   8010016c <bread>
8010144b:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010144d:	8b 43 04             	mov    0x4(%ebx),%eax
80101450:	83 e0 07             	and    $0x7,%eax
80101453:	c1 e0 06             	shl    $0x6,%eax
80101456:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010145a:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
8010145e:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101461:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101465:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101469:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010146d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101471:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101475:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101479:	8b 53 58             	mov    0x58(%ebx),%edx
8010147c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010147f:	83 c3 5c             	add    $0x5c,%ebx
80101482:	83 c0 0c             	add    $0xc,%eax
80101485:	83 c4 0c             	add    $0xc,%esp
80101488:	6a 34                	push   $0x34
8010148a:	53                   	push   %ebx
8010148b:	50                   	push   %eax
8010148c:	e8 06 29 00 00       	call   80103d97 <memmove>
  log_write(bp);
80101491:	89 34 24             	mov    %esi,(%esp)
80101494:	e8 03 15 00 00       	call   8010299c <log_write>
  brelse(bp);
80101499:	89 34 24             	mov    %esi,(%esp)
8010149c:	e8 34 ed ff ff       	call   801001d5 <brelse>
}
801014a1:	83 c4 10             	add    $0x10,%esp
801014a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014a7:	5b                   	pop    %ebx
801014a8:	5e                   	pop    %esi
801014a9:	5d                   	pop    %ebp
801014aa:	c3                   	ret    

801014ab <itrunc>:
{
801014ab:	55                   	push   %ebp
801014ac:	89 e5                	mov    %esp,%ebp
801014ae:	57                   	push   %edi
801014af:	56                   	push   %esi
801014b0:	53                   	push   %ebx
801014b1:	83 ec 1c             	sub    $0x1c,%esp
801014b4:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
801014bb:	eb 03                	jmp    801014c0 <itrunc+0x15>
801014bd:	83 c3 01             	add    $0x1,%ebx
801014c0:	83 fb 0b             	cmp    $0xb,%ebx
801014c3:	7f 19                	jg     801014de <itrunc+0x33>
    if(ip->addrs[i]){
801014c5:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014c9:	85 d2                	test   %edx,%edx
801014cb:	74 f0                	je     801014bd <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014cd:	8b 06                	mov    (%esi),%eax
801014cf:	e8 a2 fd ff ff       	call   80101276 <bfree>
      ip->addrs[i] = 0;
801014d4:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014db:	00 
801014dc:	eb df                	jmp    801014bd <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014de:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014e4:	85 c0                	test   %eax,%eax
801014e6:	75 1b                	jne    80101503 <itrunc+0x58>
  ip->size = 0;
801014e8:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014ef:	83 ec 0c             	sub    $0xc,%esp
801014f2:	56                   	push   %esi
801014f3:	e8 34 ff ff ff       	call   8010142c <iupdate>
}
801014f8:	83 c4 10             	add    $0x10,%esp
801014fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014fe:	5b                   	pop    %ebx
801014ff:	5e                   	pop    %esi
80101500:	5f                   	pop    %edi
80101501:	5d                   	pop    %ebp
80101502:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101503:	83 ec 08             	sub    $0x8,%esp
80101506:	50                   	push   %eax
80101507:	ff 36                	pushl  (%esi)
80101509:	e8 5e ec ff ff       	call   8010016c <bread>
8010150e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101511:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101514:	83 c4 10             	add    $0x10,%esp
80101517:	bb 00 00 00 00       	mov    $0x0,%ebx
8010151c:	eb 03                	jmp    80101521 <itrunc+0x76>
8010151e:	83 c3 01             	add    $0x1,%ebx
80101521:	83 fb 7f             	cmp    $0x7f,%ebx
80101524:	77 10                	ja     80101536 <itrunc+0x8b>
      if(a[j])
80101526:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101529:	85 d2                	test   %edx,%edx
8010152b:	74 f1                	je     8010151e <itrunc+0x73>
        bfree(ip->dev, a[j]);
8010152d:	8b 06                	mov    (%esi),%eax
8010152f:	e8 42 fd ff ff       	call   80101276 <bfree>
80101534:	eb e8                	jmp    8010151e <itrunc+0x73>
    brelse(bp);
80101536:	83 ec 0c             	sub    $0xc,%esp
80101539:	ff 75 e4             	pushl  -0x1c(%ebp)
8010153c:	e8 94 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101541:	8b 06                	mov    (%esi),%eax
80101543:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101549:	e8 28 fd ff ff       	call   80101276 <bfree>
    ip->addrs[NDIRECT] = 0;
8010154e:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101555:	00 00 00 
80101558:	83 c4 10             	add    $0x10,%esp
8010155b:	eb 8b                	jmp    801014e8 <itrunc+0x3d>

8010155d <idup>:
{
8010155d:	55                   	push   %ebp
8010155e:	89 e5                	mov    %esp,%ebp
80101560:	53                   	push   %ebx
80101561:	83 ec 10             	sub    $0x10,%esp
80101564:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101567:	68 00 fa 12 80       	push   $0x8012fa00
8010156c:	e8 ff 26 00 00       	call   80103c70 <acquire>
  ip->ref++;
80101571:	8b 43 08             	mov    0x8(%ebx),%eax
80101574:	83 c0 01             	add    $0x1,%eax
80101577:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010157a:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
80101581:	e8 4f 27 00 00       	call   80103cd5 <release>
}
80101586:	89 d8                	mov    %ebx,%eax
80101588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010158b:	c9                   	leave  
8010158c:	c3                   	ret    

8010158d <ilock>:
{
8010158d:	55                   	push   %ebp
8010158e:	89 e5                	mov    %esp,%ebp
80101590:	56                   	push   %esi
80101591:	53                   	push   %ebx
80101592:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101595:	85 db                	test   %ebx,%ebx
80101597:	74 22                	je     801015bb <ilock+0x2e>
80101599:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010159d:	7e 1c                	jle    801015bb <ilock+0x2e>
  acquiresleep(&ip->lock);
8010159f:	83 ec 0c             	sub    $0xc,%esp
801015a2:	8d 43 0c             	lea    0xc(%ebx),%eax
801015a5:	50                   	push   %eax
801015a6:	e8 b1 24 00 00       	call   80103a5c <acquiresleep>
  if(ip->valid == 0){
801015ab:	83 c4 10             	add    $0x10,%esp
801015ae:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015b2:	74 14                	je     801015c8 <ilock+0x3b>
}
801015b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015b7:	5b                   	pop    %ebx
801015b8:	5e                   	pop    %esi
801015b9:	5d                   	pop    %ebp
801015ba:	c3                   	ret    
    panic("ilock");
801015bb:	83 ec 0c             	sub    $0xc,%esp
801015be:	68 ca 66 10 80       	push   $0x801066ca
801015c3:	e8 80 ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015c8:	8b 43 04             	mov    0x4(%ebx),%eax
801015cb:	c1 e8 03             	shr    $0x3,%eax
801015ce:	03 05 f4 f9 12 80    	add    0x8012f9f4,%eax
801015d4:	83 ec 08             	sub    $0x8,%esp
801015d7:	50                   	push   %eax
801015d8:	ff 33                	pushl  (%ebx)
801015da:	e8 8d eb ff ff       	call   8010016c <bread>
801015df:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015e1:	8b 43 04             	mov    0x4(%ebx),%eax
801015e4:	83 e0 07             	and    $0x7,%eax
801015e7:	c1 e0 06             	shl    $0x6,%eax
801015ea:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015ee:	0f b7 10             	movzwl (%eax),%edx
801015f1:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015f5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015f9:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015fd:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101601:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101605:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101609:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010160d:	8b 50 08             	mov    0x8(%eax),%edx
80101610:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101613:	83 c0 0c             	add    $0xc,%eax
80101616:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101619:	83 c4 0c             	add    $0xc,%esp
8010161c:	6a 34                	push   $0x34
8010161e:	50                   	push   %eax
8010161f:	52                   	push   %edx
80101620:	e8 72 27 00 00       	call   80103d97 <memmove>
    brelse(bp);
80101625:	89 34 24             	mov    %esi,(%esp)
80101628:	e8 a8 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
8010162d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101634:	83 c4 10             	add    $0x10,%esp
80101637:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010163c:	0f 85 72 ff ff ff    	jne    801015b4 <ilock+0x27>
      panic("ilock: no type");
80101642:	83 ec 0c             	sub    $0xc,%esp
80101645:	68 d0 66 10 80       	push   $0x801066d0
8010164a:	e8 f9 ec ff ff       	call   80100348 <panic>

8010164f <iunlock>:
{
8010164f:	55                   	push   %ebp
80101650:	89 e5                	mov    %esp,%ebp
80101652:	56                   	push   %esi
80101653:	53                   	push   %ebx
80101654:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101657:	85 db                	test   %ebx,%ebx
80101659:	74 2c                	je     80101687 <iunlock+0x38>
8010165b:	8d 73 0c             	lea    0xc(%ebx),%esi
8010165e:	83 ec 0c             	sub    $0xc,%esp
80101661:	56                   	push   %esi
80101662:	e8 7f 24 00 00       	call   80103ae6 <holdingsleep>
80101667:	83 c4 10             	add    $0x10,%esp
8010166a:	85 c0                	test   %eax,%eax
8010166c:	74 19                	je     80101687 <iunlock+0x38>
8010166e:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101672:	7e 13                	jle    80101687 <iunlock+0x38>
  releasesleep(&ip->lock);
80101674:	83 ec 0c             	sub    $0xc,%esp
80101677:	56                   	push   %esi
80101678:	e8 2e 24 00 00       	call   80103aab <releasesleep>
}
8010167d:	83 c4 10             	add    $0x10,%esp
80101680:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101683:	5b                   	pop    %ebx
80101684:	5e                   	pop    %esi
80101685:	5d                   	pop    %ebp
80101686:	c3                   	ret    
    panic("iunlock");
80101687:	83 ec 0c             	sub    $0xc,%esp
8010168a:	68 df 66 10 80       	push   $0x801066df
8010168f:	e8 b4 ec ff ff       	call   80100348 <panic>

80101694 <iput>:
{
80101694:	55                   	push   %ebp
80101695:	89 e5                	mov    %esp,%ebp
80101697:	57                   	push   %edi
80101698:	56                   	push   %esi
80101699:	53                   	push   %ebx
8010169a:	83 ec 18             	sub    $0x18,%esp
8010169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801016a0:	8d 73 0c             	lea    0xc(%ebx),%esi
801016a3:	56                   	push   %esi
801016a4:	e8 b3 23 00 00       	call   80103a5c <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016a9:	83 c4 10             	add    $0x10,%esp
801016ac:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016b0:	74 07                	je     801016b9 <iput+0x25>
801016b2:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016b7:	74 35                	je     801016ee <iput+0x5a>
  releasesleep(&ip->lock);
801016b9:	83 ec 0c             	sub    $0xc,%esp
801016bc:	56                   	push   %esi
801016bd:	e8 e9 23 00 00       	call   80103aab <releasesleep>
  acquire(&icache.lock);
801016c2:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016c9:	e8 a2 25 00 00       	call   80103c70 <acquire>
  ip->ref--;
801016ce:	8b 43 08             	mov    0x8(%ebx),%eax
801016d1:	83 e8 01             	sub    $0x1,%eax
801016d4:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016d7:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016de:	e8 f2 25 00 00       	call   80103cd5 <release>
}
801016e3:	83 c4 10             	add    $0x10,%esp
801016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016e9:	5b                   	pop    %ebx
801016ea:	5e                   	pop    %esi
801016eb:	5f                   	pop    %edi
801016ec:	5d                   	pop    %ebp
801016ed:	c3                   	ret    
    acquire(&icache.lock);
801016ee:	83 ec 0c             	sub    $0xc,%esp
801016f1:	68 00 fa 12 80       	push   $0x8012fa00
801016f6:	e8 75 25 00 00       	call   80103c70 <acquire>
    int r = ip->ref;
801016fb:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016fe:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
80101705:	e8 cb 25 00 00       	call   80103cd5 <release>
    if(r == 1){
8010170a:	83 c4 10             	add    $0x10,%esp
8010170d:	83 ff 01             	cmp    $0x1,%edi
80101710:	75 a7                	jne    801016b9 <iput+0x25>
      itrunc(ip);
80101712:	89 d8                	mov    %ebx,%eax
80101714:	e8 92 fd ff ff       	call   801014ab <itrunc>
      ip->type = 0;
80101719:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
8010171f:	83 ec 0c             	sub    $0xc,%esp
80101722:	53                   	push   %ebx
80101723:	e8 04 fd ff ff       	call   8010142c <iupdate>
      ip->valid = 0;
80101728:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
8010172f:	83 c4 10             	add    $0x10,%esp
80101732:	eb 85                	jmp    801016b9 <iput+0x25>

80101734 <iunlockput>:
{
80101734:	55                   	push   %ebp
80101735:	89 e5                	mov    %esp,%ebp
80101737:	53                   	push   %ebx
80101738:	83 ec 10             	sub    $0x10,%esp
8010173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
8010173e:	53                   	push   %ebx
8010173f:	e8 0b ff ff ff       	call   8010164f <iunlock>
  iput(ip);
80101744:	89 1c 24             	mov    %ebx,(%esp)
80101747:	e8 48 ff ff ff       	call   80101694 <iput>
}
8010174c:	83 c4 10             	add    $0x10,%esp
8010174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101752:	c9                   	leave  
80101753:	c3                   	ret    

80101754 <stati>:
{
80101754:	55                   	push   %ebp
80101755:	89 e5                	mov    %esp,%ebp
80101757:	8b 55 08             	mov    0x8(%ebp),%edx
8010175a:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
8010175d:	8b 0a                	mov    (%edx),%ecx
8010175f:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101762:	8b 4a 04             	mov    0x4(%edx),%ecx
80101765:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101768:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010176c:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
8010176f:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101773:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101777:	8b 52 58             	mov    0x58(%edx),%edx
8010177a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010177d:	5d                   	pop    %ebp
8010177e:	c3                   	ret    

8010177f <readi>:
{
8010177f:	55                   	push   %ebp
80101780:	89 e5                	mov    %esp,%ebp
80101782:	57                   	push   %edi
80101783:	56                   	push   %esi
80101784:	53                   	push   %ebx
80101785:	83 ec 1c             	sub    $0x1c,%esp
80101788:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010178b:	8b 45 08             	mov    0x8(%ebp),%eax
8010178e:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101793:	74 2c                	je     801017c1 <readi+0x42>
  if(off > ip->size || off + n < off)
80101795:	8b 45 08             	mov    0x8(%ebp),%eax
80101798:	8b 40 58             	mov    0x58(%eax),%eax
8010179b:	39 f8                	cmp    %edi,%eax
8010179d:	0f 82 cb 00 00 00    	jb     8010186e <readi+0xef>
801017a3:	89 fa                	mov    %edi,%edx
801017a5:	03 55 14             	add    0x14(%ebp),%edx
801017a8:	0f 82 c7 00 00 00    	jb     80101875 <readi+0xf6>
  if(off + n > ip->size)
801017ae:	39 d0                	cmp    %edx,%eax
801017b0:	73 05                	jae    801017b7 <readi+0x38>
    n = ip->size - off;
801017b2:	29 f8                	sub    %edi,%eax
801017b4:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017b7:	be 00 00 00 00       	mov    $0x0,%esi
801017bc:	e9 8f 00 00 00       	jmp    80101850 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017c1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017c5:	66 83 f8 09          	cmp    $0x9,%ax
801017c9:	0f 87 91 00 00 00    	ja     80101860 <readi+0xe1>
801017cf:	98                   	cwtl   
801017d0:	8b 04 c5 80 f9 12 80 	mov    -0x7fed0680(,%eax,8),%eax
801017d7:	85 c0                	test   %eax,%eax
801017d9:	0f 84 88 00 00 00    	je     80101867 <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017df:	83 ec 04             	sub    $0x4,%esp
801017e2:	ff 75 14             	pushl  0x14(%ebp)
801017e5:	ff 75 0c             	pushl  0xc(%ebp)
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	ff d0                	call   *%eax
801017ed:	83 c4 10             	add    $0x10,%esp
801017f0:	eb 66                	jmp    80101858 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017f2:	89 fa                	mov    %edi,%edx
801017f4:	c1 ea 09             	shr    $0x9,%edx
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	e8 ee f8 ff ff       	call   801010ed <bmap>
801017ff:	83 ec 08             	sub    $0x8,%esp
80101802:	50                   	push   %eax
80101803:	8b 45 08             	mov    0x8(%ebp),%eax
80101806:	ff 30                	pushl  (%eax)
80101808:	e8 5f e9 ff ff       	call   8010016c <bread>
8010180d:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
8010180f:	89 f8                	mov    %edi,%eax
80101811:	25 ff 01 00 00       	and    $0x1ff,%eax
80101816:	bb 00 02 00 00       	mov    $0x200,%ebx
8010181b:	29 c3                	sub    %eax,%ebx
8010181d:	8b 55 14             	mov    0x14(%ebp),%edx
80101820:	29 f2                	sub    %esi,%edx
80101822:	83 c4 0c             	add    $0xc,%esp
80101825:	39 d3                	cmp    %edx,%ebx
80101827:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010182a:	53                   	push   %ebx
8010182b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010182e:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101832:	50                   	push   %eax
80101833:	ff 75 0c             	pushl  0xc(%ebp)
80101836:	e8 5c 25 00 00       	call   80103d97 <memmove>
    brelse(bp);
8010183b:	83 c4 04             	add    $0x4,%esp
8010183e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101841:	e8 8f e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101846:	01 de                	add    %ebx,%esi
80101848:	01 df                	add    %ebx,%edi
8010184a:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010184d:	83 c4 10             	add    $0x10,%esp
80101850:	39 75 14             	cmp    %esi,0x14(%ebp)
80101853:	77 9d                	ja     801017f2 <readi+0x73>
  return n;
80101855:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101858:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010185b:	5b                   	pop    %ebx
8010185c:	5e                   	pop    %esi
8010185d:	5f                   	pop    %edi
8010185e:	5d                   	pop    %ebp
8010185f:	c3                   	ret    
      return -1;
80101860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101865:	eb f1                	jmp    80101858 <readi+0xd9>
80101867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186c:	eb ea                	jmp    80101858 <readi+0xd9>
    return -1;
8010186e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101873:	eb e3                	jmp    80101858 <readi+0xd9>
80101875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010187a:	eb dc                	jmp    80101858 <readi+0xd9>

8010187c <writei>:
{
8010187c:	55                   	push   %ebp
8010187d:	89 e5                	mov    %esp,%ebp
8010187f:	57                   	push   %edi
80101880:	56                   	push   %esi
80101881:	53                   	push   %ebx
80101882:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101885:	8b 45 08             	mov    0x8(%ebp),%eax
80101888:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010188d:	74 2f                	je     801018be <writei+0x42>
  if(off > ip->size || off + n < off)
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101895:	39 48 58             	cmp    %ecx,0x58(%eax)
80101898:	0f 82 f4 00 00 00    	jb     80101992 <writei+0x116>
8010189e:	89 c8                	mov    %ecx,%eax
801018a0:	03 45 14             	add    0x14(%ebp),%eax
801018a3:	0f 82 f0 00 00 00    	jb     80101999 <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
801018a9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018ae:	0f 87 ec 00 00 00    	ja     801019a0 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018b4:	be 00 00 00 00       	mov    $0x0,%esi
801018b9:	e9 94 00 00 00       	jmp    80101952 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018be:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018c2:	66 83 f8 09          	cmp    $0x9,%ax
801018c6:	0f 87 b8 00 00 00    	ja     80101984 <writei+0x108>
801018cc:	98                   	cwtl   
801018cd:	8b 04 c5 84 f9 12 80 	mov    -0x7fed067c(,%eax,8),%eax
801018d4:	85 c0                	test   %eax,%eax
801018d6:	0f 84 af 00 00 00    	je     8010198b <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018dc:	83 ec 04             	sub    $0x4,%esp
801018df:	ff 75 14             	pushl  0x14(%ebp)
801018e2:	ff 75 0c             	pushl  0xc(%ebp)
801018e5:	ff 75 08             	pushl  0x8(%ebp)
801018e8:	ff d0                	call   *%eax
801018ea:	83 c4 10             	add    $0x10,%esp
801018ed:	eb 7c                	jmp    8010196b <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018ef:	8b 55 10             	mov    0x10(%ebp),%edx
801018f2:	c1 ea 09             	shr    $0x9,%edx
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	e8 f0 f7 ff ff       	call   801010ed <bmap>
801018fd:	83 ec 08             	sub    $0x8,%esp
80101900:	50                   	push   %eax
80101901:	8b 45 08             	mov    0x8(%ebp),%eax
80101904:	ff 30                	pushl  (%eax)
80101906:	e8 61 e8 ff ff       	call   8010016c <bread>
8010190b:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
8010190d:	8b 45 10             	mov    0x10(%ebp),%eax
80101910:	25 ff 01 00 00       	and    $0x1ff,%eax
80101915:	bb 00 02 00 00       	mov    $0x200,%ebx
8010191a:	29 c3                	sub    %eax,%ebx
8010191c:	8b 55 14             	mov    0x14(%ebp),%edx
8010191f:	29 f2                	sub    %esi,%edx
80101921:	83 c4 0c             	add    $0xc,%esp
80101924:	39 d3                	cmp    %edx,%ebx
80101926:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101929:	53                   	push   %ebx
8010192a:	ff 75 0c             	pushl  0xc(%ebp)
8010192d:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101931:	50                   	push   %eax
80101932:	e8 60 24 00 00       	call   80103d97 <memmove>
    log_write(bp);
80101937:	89 3c 24             	mov    %edi,(%esp)
8010193a:	e8 5d 10 00 00       	call   8010299c <log_write>
    brelse(bp);
8010193f:	89 3c 24             	mov    %edi,(%esp)
80101942:	e8 8e e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101947:	01 de                	add    %ebx,%esi
80101949:	01 5d 10             	add    %ebx,0x10(%ebp)
8010194c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010194f:	83 c4 10             	add    $0x10,%esp
80101952:	3b 75 14             	cmp    0x14(%ebp),%esi
80101955:	72 98                	jb     801018ef <writei+0x73>
  if(n > 0 && off > ip->size){
80101957:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010195b:	74 0b                	je     80101968 <writei+0xec>
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101963:	39 48 58             	cmp    %ecx,0x58(%eax)
80101966:	72 0b                	jb     80101973 <writei+0xf7>
  return n;
80101968:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010196b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010196e:	5b                   	pop    %ebx
8010196f:	5e                   	pop    %esi
80101970:	5f                   	pop    %edi
80101971:	5d                   	pop    %ebp
80101972:	c3                   	ret    
    ip->size = off;
80101973:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
80101976:	83 ec 0c             	sub    $0xc,%esp
80101979:	50                   	push   %eax
8010197a:	e8 ad fa ff ff       	call   8010142c <iupdate>
8010197f:	83 c4 10             	add    $0x10,%esp
80101982:	eb e4                	jmp    80101968 <writei+0xec>
      return -1;
80101984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101989:	eb e0                	jmp    8010196b <writei+0xef>
8010198b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101990:	eb d9                	jmp    8010196b <writei+0xef>
    return -1;
80101992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101997:	eb d2                	jmp    8010196b <writei+0xef>
80101999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010199e:	eb cb                	jmp    8010196b <writei+0xef>
    return -1;
801019a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019a5:	eb c4                	jmp    8010196b <writei+0xef>

801019a7 <namecmp>:
{
801019a7:	55                   	push   %ebp
801019a8:	89 e5                	mov    %esp,%ebp
801019aa:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019ad:	6a 0e                	push   $0xe
801019af:	ff 75 0c             	pushl  0xc(%ebp)
801019b2:	ff 75 08             	pushl  0x8(%ebp)
801019b5:	e8 44 24 00 00       	call   80103dfe <strncmp>
}
801019ba:	c9                   	leave  
801019bb:	c3                   	ret    

801019bc <dirlookup>:
{
801019bc:	55                   	push   %ebp
801019bd:	89 e5                	mov    %esp,%ebp
801019bf:	57                   	push   %edi
801019c0:	56                   	push   %esi
801019c1:	53                   	push   %ebx
801019c2:	83 ec 1c             	sub    $0x1c,%esp
801019c5:	8b 75 08             	mov    0x8(%ebp),%esi
801019c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019cb:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019d0:	75 07                	jne    801019d9 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801019d7:	eb 1d                	jmp    801019f6 <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019d9:	83 ec 0c             	sub    $0xc,%esp
801019dc:	68 e7 66 10 80       	push   $0x801066e7
801019e1:	e8 62 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 f9 66 10 80       	push   $0x801066f9
801019ee:	e8 55 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019f3:	83 c3 10             	add    $0x10,%ebx
801019f6:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019f9:	76 48                	jbe    80101a43 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019fb:	6a 10                	push   $0x10
801019fd:	53                   	push   %ebx
801019fe:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101a01:	50                   	push   %eax
80101a02:	56                   	push   %esi
80101a03:	e8 77 fd ff ff       	call   8010177f <readi>
80101a08:	83 c4 10             	add    $0x10,%esp
80101a0b:	83 f8 10             	cmp    $0x10,%eax
80101a0e:	75 d6                	jne    801019e6 <dirlookup+0x2a>
    if(de.inum == 0)
80101a10:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a15:	74 dc                	je     801019f3 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a17:	83 ec 08             	sub    $0x8,%esp
80101a1a:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a1d:	50                   	push   %eax
80101a1e:	57                   	push   %edi
80101a1f:	e8 83 ff ff ff       	call   801019a7 <namecmp>
80101a24:	83 c4 10             	add    $0x10,%esp
80101a27:	85 c0                	test   %eax,%eax
80101a29:	75 c8                	jne    801019f3 <dirlookup+0x37>
      if(poff)
80101a2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a2f:	74 05                	je     80101a36 <dirlookup+0x7a>
        *poff = off;
80101a31:	8b 45 10             	mov    0x10(%ebp),%eax
80101a34:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a36:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a3a:	8b 06                	mov    (%esi),%eax
80101a3c:	e8 52 f7 ff ff       	call   80101193 <iget>
80101a41:	eb 05                	jmp    80101a48 <dirlookup+0x8c>
  return 0;
80101a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a4b:	5b                   	pop    %ebx
80101a4c:	5e                   	pop    %esi
80101a4d:	5f                   	pop    %edi
80101a4e:	5d                   	pop    %ebp
80101a4f:	c3                   	ret    

80101a50 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a50:	55                   	push   %ebp
80101a51:	89 e5                	mov    %esp,%ebp
80101a53:	57                   	push   %edi
80101a54:	56                   	push   %esi
80101a55:	53                   	push   %ebx
80101a56:	83 ec 1c             	sub    $0x1c,%esp
80101a59:	89 c6                	mov    %eax,%esi
80101a5b:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a61:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a64:	74 17                	je     80101a7d <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a66:	e8 63 18 00 00       	call   801032ce <myproc>
80101a6b:	83 ec 0c             	sub    $0xc,%esp
80101a6e:	ff 70 68             	pushl  0x68(%eax)
80101a71:	e8 e7 fa ff ff       	call   8010155d <idup>
80101a76:	89 c3                	mov    %eax,%ebx
80101a78:	83 c4 10             	add    $0x10,%esp
80101a7b:	eb 53                	jmp    80101ad0 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a7d:	ba 01 00 00 00       	mov    $0x1,%edx
80101a82:	b8 01 00 00 00       	mov    $0x1,%eax
80101a87:	e8 07 f7 ff ff       	call   80101193 <iget>
80101a8c:	89 c3                	mov    %eax,%ebx
80101a8e:	eb 40                	jmp    80101ad0 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a90:	83 ec 0c             	sub    $0xc,%esp
80101a93:	53                   	push   %ebx
80101a94:	e8 9b fc ff ff       	call   80101734 <iunlockput>
      return 0;
80101a99:	83 c4 10             	add    $0x10,%esp
80101a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101aa1:	89 d8                	mov    %ebx,%eax
80101aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aa6:	5b                   	pop    %ebx
80101aa7:	5e                   	pop    %esi
80101aa8:	5f                   	pop    %edi
80101aa9:	5d                   	pop    %ebp
80101aaa:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101aab:	83 ec 04             	sub    $0x4,%esp
80101aae:	6a 00                	push   $0x0
80101ab0:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ab3:	53                   	push   %ebx
80101ab4:	e8 03 ff ff ff       	call   801019bc <dirlookup>
80101ab9:	89 c7                	mov    %eax,%edi
80101abb:	83 c4 10             	add    $0x10,%esp
80101abe:	85 c0                	test   %eax,%eax
80101ac0:	74 4a                	je     80101b0c <namex+0xbc>
    iunlockput(ip);
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	53                   	push   %ebx
80101ac6:	e8 69 fc ff ff       	call   80101734 <iunlockput>
    ip = next;
80101acb:	83 c4 10             	add    $0x10,%esp
80101ace:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ad3:	89 f0                	mov    %esi,%eax
80101ad5:	e8 77 f4 ff ff       	call   80100f51 <skipelem>
80101ada:	89 c6                	mov    %eax,%esi
80101adc:	85 c0                	test   %eax,%eax
80101ade:	74 3c                	je     80101b1c <namex+0xcc>
    ilock(ip);
80101ae0:	83 ec 0c             	sub    $0xc,%esp
80101ae3:	53                   	push   %ebx
80101ae4:	e8 a4 fa ff ff       	call   8010158d <ilock>
    if(ip->type != T_DIR){
80101ae9:	83 c4 10             	add    $0x10,%esp
80101aec:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101af1:	75 9d                	jne    80101a90 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101af3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101af7:	74 b2                	je     80101aab <namex+0x5b>
80101af9:	80 3e 00             	cmpb   $0x0,(%esi)
80101afc:	75 ad                	jne    80101aab <namex+0x5b>
      iunlock(ip);
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	53                   	push   %ebx
80101b02:	e8 48 fb ff ff       	call   8010164f <iunlock>
      return ip;
80101b07:	83 c4 10             	add    $0x10,%esp
80101b0a:	eb 95                	jmp    80101aa1 <namex+0x51>
      iunlockput(ip);
80101b0c:	83 ec 0c             	sub    $0xc,%esp
80101b0f:	53                   	push   %ebx
80101b10:	e8 1f fc ff ff       	call   80101734 <iunlockput>
      return 0;
80101b15:	83 c4 10             	add    $0x10,%esp
80101b18:	89 fb                	mov    %edi,%ebx
80101b1a:	eb 85                	jmp    80101aa1 <namex+0x51>
  if(nameiparent){
80101b1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b20:	0f 84 7b ff ff ff    	je     80101aa1 <namex+0x51>
    iput(ip);
80101b26:	83 ec 0c             	sub    $0xc,%esp
80101b29:	53                   	push   %ebx
80101b2a:	e8 65 fb ff ff       	call   80101694 <iput>
    return 0;
80101b2f:	83 c4 10             	add    $0x10,%esp
80101b32:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b37:	e9 65 ff ff ff       	jmp    80101aa1 <namex+0x51>

80101b3c <dirlink>:
{
80101b3c:	55                   	push   %ebp
80101b3d:	89 e5                	mov    %esp,%ebp
80101b3f:	57                   	push   %edi
80101b40:	56                   	push   %esi
80101b41:	53                   	push   %ebx
80101b42:	83 ec 20             	sub    $0x20,%esp
80101b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b48:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b4b:	6a 00                	push   $0x0
80101b4d:	57                   	push   %edi
80101b4e:	53                   	push   %ebx
80101b4f:	e8 68 fe ff ff       	call   801019bc <dirlookup>
80101b54:	83 c4 10             	add    $0x10,%esp
80101b57:	85 c0                	test   %eax,%eax
80101b59:	75 2d                	jne    80101b88 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b5b:	b8 00 00 00 00       	mov    $0x0,%eax
80101b60:	89 c6                	mov    %eax,%esi
80101b62:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b65:	76 41                	jbe    80101ba8 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b67:	6a 10                	push   $0x10
80101b69:	50                   	push   %eax
80101b6a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b6d:	50                   	push   %eax
80101b6e:	53                   	push   %ebx
80101b6f:	e8 0b fc ff ff       	call   8010177f <readi>
80101b74:	83 c4 10             	add    $0x10,%esp
80101b77:	83 f8 10             	cmp    $0x10,%eax
80101b7a:	75 1f                	jne    80101b9b <dirlink+0x5f>
    if(de.inum == 0)
80101b7c:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b81:	74 25                	je     80101ba8 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b83:	8d 46 10             	lea    0x10(%esi),%eax
80101b86:	eb d8                	jmp    80101b60 <dirlink+0x24>
    iput(ip);
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	50                   	push   %eax
80101b8c:	e8 03 fb ff ff       	call   80101694 <iput>
    return -1;
80101b91:	83 c4 10             	add    $0x10,%esp
80101b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b99:	eb 3d                	jmp    80101bd8 <dirlink+0x9c>
      panic("dirlink read");
80101b9b:	83 ec 0c             	sub    $0xc,%esp
80101b9e:	68 08 67 10 80       	push   $0x80106708
80101ba3:	e8 a0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101ba8:	83 ec 04             	sub    $0x4,%esp
80101bab:	6a 0e                	push   $0xe
80101bad:	57                   	push   %edi
80101bae:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bb1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bb4:	50                   	push   %eax
80101bb5:	e8 81 22 00 00       	call   80103e3b <strncpy>
  de.inum = inum;
80101bba:	8b 45 10             	mov    0x10(%ebp),%eax
80101bbd:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bc1:	6a 10                	push   $0x10
80101bc3:	56                   	push   %esi
80101bc4:	57                   	push   %edi
80101bc5:	53                   	push   %ebx
80101bc6:	e8 b1 fc ff ff       	call   8010187c <writei>
80101bcb:	83 c4 20             	add    $0x20,%esp
80101bce:	83 f8 10             	cmp    $0x10,%eax
80101bd1:	75 0d                	jne    80101be0 <dirlink+0xa4>
  return 0;
80101bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bdb:	5b                   	pop    %ebx
80101bdc:	5e                   	pop    %esi
80101bdd:	5f                   	pop    %edi
80101bde:	5d                   	pop    %ebp
80101bdf:	c3                   	ret    
    panic("dirlink");
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 14 6d 10 80       	push   $0x80106d14
80101be8:	e8 5b e7 ff ff       	call   80100348 <panic>

80101bed <namei>:

struct inode*
namei(char *path)
{
80101bed:	55                   	push   %ebp
80101bee:	89 e5                	mov    %esp,%ebp
80101bf0:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bf3:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bf6:	ba 00 00 00 00       	mov    $0x0,%edx
80101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfe:	e8 4d fe ff ff       	call   80101a50 <namex>
}
80101c03:	c9                   	leave  
80101c04:	c3                   	ret    

80101c05 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101c05:	55                   	push   %ebp
80101c06:	89 e5                	mov    %esp,%ebp
80101c08:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c0e:	ba 01 00 00 00       	mov    $0x1,%edx
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	e8 35 fe ff ff       	call   80101a50 <namex>
}
80101c1b:	c9                   	leave  
80101c1c:	c3                   	ret    

80101c1d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c1d:	55                   	push   %ebp
80101c1e:	89 e5                	mov    %esp,%ebp
80101c20:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c22:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c27:	ec                   	in     (%dx),%al
80101c28:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c2a:	83 e0 c0             	and    $0xffffffc0,%eax
80101c2d:	3c 40                	cmp    $0x40,%al
80101c2f:	75 f1                	jne    80101c22 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c31:	85 c9                	test   %ecx,%ecx
80101c33:	74 0c                	je     80101c41 <idewait+0x24>
80101c35:	f6 c2 21             	test   $0x21,%dl
80101c38:	75 0e                	jne    80101c48 <idewait+0x2b>
    return -1;
  return 0;
80101c3a:	b8 00 00 00 00       	mov    $0x0,%eax
80101c3f:	eb 05                	jmp    80101c46 <idewait+0x29>
80101c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c46:	5d                   	pop    %ebp
80101c47:	c3                   	ret    
    return -1;
80101c48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c4d:	eb f7                	jmp    80101c46 <idewait+0x29>

80101c4f <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	56                   	push   %esi
80101c53:	53                   	push   %ebx
  if(b == 0)
80101c54:	85 c0                	test   %eax,%eax
80101c56:	74 7d                	je     80101cd5 <idestart+0x86>
80101c58:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c5a:	8b 58 08             	mov    0x8(%eax),%ebx
80101c5d:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c63:	77 7d                	ja     80101ce2 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c65:	b8 00 00 00 00       	mov    $0x0,%eax
80101c6a:	e8 ae ff ff ff       	call   80101c1d <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c6f:	b8 00 00 00 00       	mov    $0x0,%eax
80101c74:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c79:	ee                   	out    %al,(%dx)
80101c7a:	b8 01 00 00 00       	mov    $0x1,%eax
80101c7f:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c84:	ee                   	out    %al,(%dx)
80101c85:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c8a:	89 d8                	mov    %ebx,%eax
80101c8c:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c8d:	89 d8                	mov    %ebx,%eax
80101c8f:	c1 f8 08             	sar    $0x8,%eax
80101c92:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c97:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c98:	89 d8                	mov    %ebx,%eax
80101c9a:	c1 f8 10             	sar    $0x10,%eax
80101c9d:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101ca2:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101ca3:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101ca7:	c1 e0 04             	shl    $0x4,%eax
80101caa:	83 e0 10             	and    $0x10,%eax
80101cad:	c1 fb 18             	sar    $0x18,%ebx
80101cb0:	83 e3 0f             	and    $0xf,%ebx
80101cb3:	09 d8                	or     %ebx,%eax
80101cb5:	83 c8 e0             	or     $0xffffffe0,%eax
80101cb8:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cbd:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cbe:	f6 06 04             	testb  $0x4,(%esi)
80101cc1:	75 2c                	jne    80101cef <idestart+0xa0>
80101cc3:	b8 20 00 00 00       	mov    $0x20,%eax
80101cc8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ccd:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cd1:	5b                   	pop    %ebx
80101cd2:	5e                   	pop    %esi
80101cd3:	5d                   	pop    %ebp
80101cd4:	c3                   	ret    
    panic("idestart");
80101cd5:	83 ec 0c             	sub    $0xc,%esp
80101cd8:	68 6b 67 10 80       	push   $0x8010676b
80101cdd:	e8 66 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	68 74 67 10 80       	push   $0x80106774
80101cea:	e8 59 e6 ff ff       	call   80100348 <panic>
80101cef:	b8 30 00 00 00       	mov    $0x30,%eax
80101cf4:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cf9:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cfa:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d07:	fc                   	cld    
80101d08:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d0a:	eb c2                	jmp    80101cce <idestart+0x7f>

80101d0c <ideinit>:
{
80101d0c:	55                   	push   %ebp
80101d0d:	89 e5                	mov    %esp,%ebp
80101d0f:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d12:	68 86 67 10 80       	push   $0x80106786
80101d17:	68 80 95 12 80       	push   $0x80129580
80101d1c:	e8 13 1e 00 00       	call   80103b34 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d21:	83 c4 08             	add    $0x8,%esp
80101d24:	a1 20 1d 13 80       	mov    0x80131d20,%eax
80101d29:	83 e8 01             	sub    $0x1,%eax
80101d2c:	50                   	push   %eax
80101d2d:	6a 0e                	push   $0xe
80101d2f:	e8 56 02 00 00       	call   80101f8a <ioapicenable>
  idewait(0);
80101d34:	b8 00 00 00 00       	mov    $0x0,%eax
80101d39:	e8 df fe ff ff       	call   80101c1d <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d3e:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d43:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d48:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d49:	83 c4 10             	add    $0x10,%esp
80101d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d51:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d57:	7f 19                	jg     80101d72 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d59:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d5e:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d5f:	84 c0                	test   %al,%al
80101d61:	75 05                	jne    80101d68 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d63:	83 c1 01             	add    $0x1,%ecx
80101d66:	eb e9                	jmp    80101d51 <ideinit+0x45>
      havedisk1 = 1;
80101d68:	c7 05 60 95 12 80 01 	movl   $0x1,0x80129560
80101d6f:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d72:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d77:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d7c:	ee                   	out    %al,(%dx)
}
80101d7d:	c9                   	leave  
80101d7e:	c3                   	ret    

80101d7f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d7f:	55                   	push   %ebp
80101d80:	89 e5                	mov    %esp,%ebp
80101d82:	57                   	push   %edi
80101d83:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d84:	83 ec 0c             	sub    $0xc,%esp
80101d87:	68 80 95 12 80       	push   $0x80129580
80101d8c:	e8 df 1e 00 00       	call   80103c70 <acquire>

  if((b = idequeue) == 0){
80101d91:	8b 1d 64 95 12 80    	mov    0x80129564,%ebx
80101d97:	83 c4 10             	add    $0x10,%esp
80101d9a:	85 db                	test   %ebx,%ebx
80101d9c:	74 48                	je     80101de6 <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d9e:	8b 43 58             	mov    0x58(%ebx),%eax
80101da1:	a3 64 95 12 80       	mov    %eax,0x80129564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101da6:	f6 03 04             	testb  $0x4,(%ebx)
80101da9:	74 4d                	je     80101df8 <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101dab:	8b 03                	mov    (%ebx),%eax
80101dad:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101db0:	83 e0 fb             	and    $0xfffffffb,%eax
80101db3:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101db5:	83 ec 0c             	sub    $0xc,%esp
80101db8:	53                   	push   %ebx
80101db9:	e8 1c 1b 00 00       	call   801038da <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101dbe:	a1 64 95 12 80       	mov    0x80129564,%eax
80101dc3:	83 c4 10             	add    $0x10,%esp
80101dc6:	85 c0                	test   %eax,%eax
80101dc8:	74 05                	je     80101dcf <ideintr+0x50>
    idestart(idequeue);
80101dca:	e8 80 fe ff ff       	call   80101c4f <idestart>

  release(&idelock);
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	68 80 95 12 80       	push   $0x80129580
80101dd7:	e8 f9 1e 00 00       	call   80103cd5 <release>
80101ddc:	83 c4 10             	add    $0x10,%esp
}
80101ddf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101de2:	5b                   	pop    %ebx
80101de3:	5f                   	pop    %edi
80101de4:	5d                   	pop    %ebp
80101de5:	c3                   	ret    
    release(&idelock);
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 80 95 12 80       	push   $0x80129580
80101dee:	e8 e2 1e 00 00       	call   80103cd5 <release>
    return;
80101df3:	83 c4 10             	add    $0x10,%esp
80101df6:	eb e7                	jmp    80101ddf <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101df8:	b8 01 00 00 00       	mov    $0x1,%eax
80101dfd:	e8 1b fe ff ff       	call   80101c1d <idewait>
80101e02:	85 c0                	test   %eax,%eax
80101e04:	78 a5                	js     80101dab <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101e06:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101e09:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e0e:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e13:	fc                   	cld    
80101e14:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e16:	eb 93                	jmp    80101dab <ideintr+0x2c>

80101e18 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e18:	55                   	push   %ebp
80101e19:	89 e5                	mov    %esp,%ebp
80101e1b:	53                   	push   %ebx
80101e1c:	83 ec 10             	sub    $0x10,%esp
80101e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e22:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e25:	50                   	push   %eax
80101e26:	e8 bb 1c 00 00       	call   80103ae6 <holdingsleep>
80101e2b:	83 c4 10             	add    $0x10,%esp
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 37                	je     80101e69 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e32:	8b 03                	mov    (%ebx),%eax
80101e34:	83 e0 06             	and    $0x6,%eax
80101e37:	83 f8 02             	cmp    $0x2,%eax
80101e3a:	74 3a                	je     80101e76 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e3c:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e40:	74 09                	je     80101e4b <iderw+0x33>
80101e42:	83 3d 60 95 12 80 00 	cmpl   $0x0,0x80129560
80101e49:	74 38                	je     80101e83 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 80 95 12 80       	push   $0x80129580
80101e53:	e8 18 1e 00 00       	call   80103c70 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e58:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e5f:	83 c4 10             	add    $0x10,%esp
80101e62:	ba 64 95 12 80       	mov    $0x80129564,%edx
80101e67:	eb 2a                	jmp    80101e93 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e69:	83 ec 0c             	sub    $0xc,%esp
80101e6c:	68 8a 67 10 80       	push   $0x8010678a
80101e71:	e8 d2 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e76:	83 ec 0c             	sub    $0xc,%esp
80101e79:	68 a0 67 10 80       	push   $0x801067a0
80101e7e:	e8 c5 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e83:	83 ec 0c             	sub    $0xc,%esp
80101e86:	68 b5 67 10 80       	push   $0x801067b5
80101e8b:	e8 b8 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e90:	8d 50 58             	lea    0x58(%eax),%edx
80101e93:	8b 02                	mov    (%edx),%eax
80101e95:	85 c0                	test   %eax,%eax
80101e97:	75 f7                	jne    80101e90 <iderw+0x78>
    ;
  *pp = b;
80101e99:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e9b:	39 1d 64 95 12 80    	cmp    %ebx,0x80129564
80101ea1:	75 1a                	jne    80101ebd <iderw+0xa5>
    idestart(b);
80101ea3:	89 d8                	mov    %ebx,%eax
80101ea5:	e8 a5 fd ff ff       	call   80101c4f <idestart>
80101eaa:	eb 11                	jmp    80101ebd <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101eac:	83 ec 08             	sub    $0x8,%esp
80101eaf:	68 80 95 12 80       	push   $0x80129580
80101eb4:	53                   	push   %ebx
80101eb5:	e8 bb 18 00 00       	call   80103775 <sleep>
80101eba:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101ebd:	8b 03                	mov    (%ebx),%eax
80101ebf:	83 e0 06             	and    $0x6,%eax
80101ec2:	83 f8 02             	cmp    $0x2,%eax
80101ec5:	75 e5                	jne    80101eac <iderw+0x94>
  }


  release(&idelock);
80101ec7:	83 ec 0c             	sub    $0xc,%esp
80101eca:	68 80 95 12 80       	push   $0x80129580
80101ecf:	e8 01 1e 00 00       	call   80103cd5 <release>
}
80101ed4:	83 c4 10             	add    $0x10,%esp
80101ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101eda:	c9                   	leave  
80101edb:	c3                   	ret    

80101edc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101edc:	55                   	push   %ebp
80101edd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101edf:	8b 15 54 16 13 80    	mov    0x80131654,%edx
80101ee5:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ee7:	a1 54 16 13 80       	mov    0x80131654,%eax
80101eec:	8b 40 10             	mov    0x10(%eax),%eax
}
80101eef:	5d                   	pop    %ebp
80101ef0:	c3                   	ret    

80101ef1 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ef1:	55                   	push   %ebp
80101ef2:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ef4:	8b 0d 54 16 13 80    	mov    0x80131654,%ecx
80101efa:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101efc:	a1 54 16 13 80       	mov    0x80131654,%eax
80101f01:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f04:	5d                   	pop    %ebp
80101f05:	c3                   	ret    

80101f06 <ioapicinit>:

void
ioapicinit(void)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	57                   	push   %edi
80101f0a:	56                   	push   %esi
80101f0b:	53                   	push   %ebx
80101f0c:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f0f:	c7 05 54 16 13 80 00 	movl   $0xfec00000,0x80131654
80101f16:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f19:	b8 01 00 00 00       	mov    $0x1,%eax
80101f1e:	e8 b9 ff ff ff       	call   80101edc <ioapicread>
80101f23:	c1 e8 10             	shr    $0x10,%eax
80101f26:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f29:	b8 00 00 00 00       	mov    $0x0,%eax
80101f2e:	e8 a9 ff ff ff       	call   80101edc <ioapicread>
80101f33:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f36:	0f b6 15 80 17 13 80 	movzbl 0x80131780,%edx
80101f3d:	39 c2                	cmp    %eax,%edx
80101f3f:	75 07                	jne    80101f48 <ioapicinit+0x42>
{
80101f41:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f46:	eb 36                	jmp    80101f7e <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f48:	83 ec 0c             	sub    $0xc,%esp
80101f4b:	68 d4 67 10 80       	push   $0x801067d4
80101f50:	e8 b6 e6 ff ff       	call   8010060b <cprintf>
80101f55:	83 c4 10             	add    $0x10,%esp
80101f58:	eb e7                	jmp    80101f41 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f5a:	8d 53 20             	lea    0x20(%ebx),%edx
80101f5d:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f63:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f67:	89 f0                	mov    %esi,%eax
80101f69:	e8 83 ff ff ff       	call   80101ef1 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f6e:	8d 46 01             	lea    0x1(%esi),%eax
80101f71:	ba 00 00 00 00       	mov    $0x0,%edx
80101f76:	e8 76 ff ff ff       	call   80101ef1 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f7b:	83 c3 01             	add    $0x1,%ebx
80101f7e:	39 fb                	cmp    %edi,%ebx
80101f80:	7e d8                	jle    80101f5a <ioapicinit+0x54>
  }
}
80101f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f85:	5b                   	pop    %ebx
80101f86:	5e                   	pop    %esi
80101f87:	5f                   	pop    %edi
80101f88:	5d                   	pop    %ebp
80101f89:	c3                   	ret    

80101f8a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f8a:	55                   	push   %ebp
80101f8b:	89 e5                	mov    %esp,%ebp
80101f8d:	53                   	push   %ebx
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f91:	8d 50 20             	lea    0x20(%eax),%edx
80101f94:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f98:	89 d8                	mov    %ebx,%eax
80101f9a:	e8 52 ff ff ff       	call   80101ef1 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fa2:	c1 e2 18             	shl    $0x18,%edx
80101fa5:	8d 43 01             	lea    0x1(%ebx),%eax
80101fa8:	e8 44 ff ff ff       	call   80101ef1 <ioapicwrite>
}
80101fad:	5b                   	pop    %ebx
80101fae:	5d                   	pop    %ebp
80101faf:	c3                   	ret    

80101fb0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fb0:	55                   	push   %ebp
80101fb1:	89 e5                	mov    %esp,%ebp
80101fb3:	53                   	push   %ebx
80101fb4:	83 ec 04             	sub    $0x4,%esp
80101fb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fba:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fc0:	75 4c                	jne    8010200e <kfree+0x5e>
80101fc2:	81 fb c8 44 13 80    	cmp    $0x801344c8,%ebx
80101fc8:	72 44                	jb     8010200e <kfree+0x5e>
80101fca:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fd0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fd5:	77 37                	ja     8010200e <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fd7:	83 ec 04             	sub    $0x4,%esp
80101fda:	68 00 10 00 00       	push   $0x1000
80101fdf:	6a 01                	push   $0x1
80101fe1:	53                   	push   %ebx
80101fe2:	e8 35 1d 00 00       	call   80103d1c <memset>

  if(kmem.use_lock)
80101fe7:	83 c4 10             	add    $0x10,%esp
80101fea:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
80101ff1:	75 28                	jne    8010201b <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101ff3:	a1 98 16 13 80       	mov    0x80131698,%eax
80101ff8:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101ffa:	89 1d 98 16 13 80    	mov    %ebx,0x80131698
  if(kmem.use_lock)
80102000:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
80102007:	75 24                	jne    8010202d <kfree+0x7d>
    release(&kmem.lock);
}
80102009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010200c:	c9                   	leave  
8010200d:	c3                   	ret    
    panic("kfree");
8010200e:	83 ec 0c             	sub    $0xc,%esp
80102011:	68 06 68 10 80       	push   $0x80106806
80102016:	e8 2d e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010201b:	83 ec 0c             	sub    $0xc,%esp
8010201e:	68 60 16 13 80       	push   $0x80131660
80102023:	e8 48 1c 00 00       	call   80103c70 <acquire>
80102028:	83 c4 10             	add    $0x10,%esp
8010202b:	eb c6                	jmp    80101ff3 <kfree+0x43>
    release(&kmem.lock);
8010202d:	83 ec 0c             	sub    $0xc,%esp
80102030:	68 60 16 13 80       	push   $0x80131660
80102035:	e8 9b 1c 00 00       	call   80103cd5 <release>
8010203a:	83 c4 10             	add    $0x10,%esp
}
8010203d:	eb ca                	jmp    80102009 <kfree+0x59>

8010203f <freerange>:
{
8010203f:	55                   	push   %ebp
80102040:	89 e5                	mov    %esp,%ebp
80102042:	56                   	push   %esi
80102043:	53                   	push   %ebx
80102044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010204f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102054:	eb 0e                	jmp    80102064 <freerange+0x25>
    kfree(p);
80102056:	83 ec 0c             	sub    $0xc,%esp
80102059:	50                   	push   %eax
8010205a:	e8 51 ff ff ff       	call   80101fb0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010205f:	83 c4 10             	add    $0x10,%esp
80102062:	89 f0                	mov    %esi,%eax
80102064:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010206a:	39 de                	cmp    %ebx,%esi
8010206c:	76 e8                	jbe    80102056 <freerange+0x17>
}
8010206e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102071:	5b                   	pop    %ebx
80102072:	5e                   	pop    %esi
80102073:	5d                   	pop    %ebp
80102074:	c3                   	ret    

80102075 <kinit1>:
{
80102075:	55                   	push   %ebp
80102076:	89 e5                	mov    %esp,%ebp
80102078:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010207b:	68 0c 68 10 80       	push   $0x8010680c
80102080:	68 60 16 13 80       	push   $0x80131660
80102085:	e8 aa 1a 00 00       	call   80103b34 <initlock>
  kmem.use_lock = 0;
8010208a:	c7 05 94 16 13 80 00 	movl   $0x0,0x80131694
80102091:	00 00 00 
  freerange(vstart, vend);
80102094:	83 c4 08             	add    $0x8,%esp
80102097:	ff 75 0c             	pushl  0xc(%ebp)
8010209a:	ff 75 08             	pushl  0x8(%ebp)
8010209d:	e8 9d ff ff ff       	call   8010203f <freerange>
}
801020a2:	83 c4 10             	add    $0x10,%esp
801020a5:	c9                   	leave  
801020a6:	c3                   	ret    

801020a7 <kinit2>:
{
801020a7:	55                   	push   %ebp
801020a8:	89 e5                	mov    %esp,%ebp
801020aa:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020ad:	ff 75 0c             	pushl  0xc(%ebp)
801020b0:	ff 75 08             	pushl  0x8(%ebp)
801020b3:	e8 87 ff ff ff       	call   8010203f <freerange>
  kmem.use_lock = 1;
801020b8:	c7 05 94 16 13 80 01 	movl   $0x1,0x80131694
801020bf:	00 00 00 
}
801020c2:	83 c4 10             	add    $0x10,%esp
801020c5:	c9                   	leave  
801020c6:	c3                   	ret    

801020c7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(int pid)
{
801020c7:	55                   	push   %ebp
801020c8:	89 e5                	mov    %esp,%ebp
801020ca:	53                   	push   %ebx
801020cb:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020ce:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
801020d5:	75 56                	jne    8010212d <kalloc+0x66>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020d7:	8b 1d 98 16 13 80    	mov    0x80131698,%ebx
  if(r) {
801020dd:	85 db                	test   %ebx,%ebx
801020df:	74 0d                	je     801020ee <kalloc+0x27>
    if (r->next) {
801020e1:	8b 03                	mov    (%ebx),%eax
801020e3:	85 c0                	test   %eax,%eax
801020e5:	74 58                	je     8010213f <kalloc+0x78>
      kmem.freelist = r->next->next;
801020e7:	8b 00                	mov    (%eax),%eax
801020e9:	a3 98 16 13 80       	mov    %eax,0x80131698
    } else {
      kmem.freelist = r->next;
    }
  }
  //
  int addr = (V2P((char*)r) >> 12);
801020ee:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801020f4:	c1 e8 0c             	shr    $0xc,%eax
  if (addr > 0x3FF) {
801020f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
801020fc:	7e 1f                	jle    8010211d <kalloc+0x56>
    frame[size] = addr;
801020fe:	8b 15 b4 95 12 80    	mov    0x801295b4,%edx
80102104:	89 04 95 00 70 11 80 	mov    %eax,-0x7fee9000(,%edx,4)
    mem_pid[size++] = pid;
8010210b:	8d 42 01             	lea    0x1(%edx),%eax
8010210e:	a3 b4 95 12 80       	mov    %eax,0x801295b4
80102113:	8b 45 08             	mov    0x8(%ebp),%eax
80102116:	89 04 95 00 70 10 80 	mov    %eax,-0x7fef9000(,%edx,4)
  }
  //
  if(kmem.use_lock)
8010211d:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
80102124:	75 20                	jne    80102146 <kalloc+0x7f>
    release(&kmem.lock);
  return (char*)r;
}
80102126:	89 d8                	mov    %ebx,%eax
80102128:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010212b:	c9                   	leave  
8010212c:	c3                   	ret    
    acquire(&kmem.lock);
8010212d:	83 ec 0c             	sub    $0xc,%esp
80102130:	68 60 16 13 80       	push   $0x80131660
80102135:	e8 36 1b 00 00       	call   80103c70 <acquire>
8010213a:	83 c4 10             	add    $0x10,%esp
8010213d:	eb 98                	jmp    801020d7 <kalloc+0x10>
      kmem.freelist = r->next;
8010213f:	a3 98 16 13 80       	mov    %eax,0x80131698
80102144:	eb a8                	jmp    801020ee <kalloc+0x27>
    release(&kmem.lock);
80102146:	83 ec 0c             	sub    $0xc,%esp
80102149:	68 60 16 13 80       	push   $0x80131660
8010214e:	e8 82 1b 00 00       	call   80103cd5 <release>
80102153:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102156:	eb ce                	jmp    80102126 <kalloc+0x5f>

80102158 <dump_physmem>:



int
dump_physmem(int *frames, int *pids, int numframes)
{
80102158:	55                   	push   %ebp
80102159:	89 e5                	mov    %esp,%ebp
8010215b:	57                   	push   %edi
8010215c:	56                   	push   %esi
8010215d:	53                   	push   %ebx
8010215e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102161:	8b 75 0c             	mov    0xc(%ebp),%esi
80102164:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if (frames == NULL || pids == NULL || numframes < 0) {
80102167:	85 db                	test   %ebx,%ebx
80102169:	0f 94 c2             	sete   %dl
8010216c:	85 f6                	test   %esi,%esi
8010216e:	0f 94 c0             	sete   %al
80102171:	08 c2                	or     %al,%dl
80102173:	75 52                	jne    801021c7 <dump_physmem+0x6f>
80102175:	85 c9                	test   %ecx,%ecx
80102177:	78 55                	js     801021ce <dump_physmem+0x76>
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
80102179:	b8 00 00 00 00       	mov    $0x0,%eax
8010217e:	eb 18                	jmp    80102198 <dump_physmem+0x40>
    if (frame[i] != 0){
      frames[i] = frame[i];
      pids[i] = mem_pid[i];
    }else{
      frames[i] = -1;
80102180:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102187:	c7 04 13 ff ff ff ff 	movl   $0xffffffff,(%ebx,%edx,1)
      pids[i] = -1;
8010218e:	c7 04 16 ff ff ff ff 	movl   $0xffffffff,(%esi,%edx,1)
  for (int i = 0; i < numframes; i++) {
80102195:	83 c0 01             	add    $0x1,%eax
80102198:	39 c8                	cmp    %ecx,%eax
8010219a:	7d 21                	jge    801021bd <dump_physmem+0x65>
    if (frame[i] != 0){
8010219c:	8b 14 85 00 70 11 80 	mov    -0x7fee9000(,%eax,4),%edx
801021a3:	85 d2                	test   %edx,%edx
801021a5:	74 d9                	je     80102180 <dump_physmem+0x28>
      frames[i] = frame[i];
801021a7:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
801021ae:	89 14 3b             	mov    %edx,(%ebx,%edi,1)
      pids[i] = mem_pid[i];
801021b1:	8b 14 85 00 70 10 80 	mov    -0x7fef9000(,%eax,4),%edx
801021b8:	89 14 3e             	mov    %edx,(%esi,%edi,1)
801021bb:	eb d8                	jmp    80102195 <dump_physmem+0x3d>
    }
  }
  return 0;
801021bd:	b8 00 00 00 00       	mov    $0x0,%eax
801021c2:	5b                   	pop    %ebx
801021c3:	5e                   	pop    %esi
801021c4:	5f                   	pop    %edi
801021c5:	5d                   	pop    %ebp
801021c6:	c3                   	ret    
      return -1;
801021c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021cc:	eb f4                	jmp    801021c2 <dump_physmem+0x6a>
801021ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021d3:	eb ed                	jmp    801021c2 <dump_physmem+0x6a>

801021d5 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801021d5:	55                   	push   %ebp
801021d6:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021d8:	ba 64 00 00 00       	mov    $0x64,%edx
801021dd:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801021de:	a8 01                	test   $0x1,%al
801021e0:	0f 84 b5 00 00 00    	je     8010229b <kbdgetc+0xc6>
801021e6:	ba 60 00 00 00       	mov    $0x60,%edx
801021eb:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801021ec:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801021ef:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801021f5:	74 5c                	je     80102253 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801021f7:	84 c0                	test   %al,%al
801021f9:	78 66                	js     80102261 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801021fb:	8b 0d b8 95 12 80    	mov    0x801295b8,%ecx
80102201:	f6 c1 40             	test   $0x40,%cl
80102204:	74 0f                	je     80102215 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102206:	83 c8 80             	or     $0xffffff80,%eax
80102209:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
8010220c:	83 e1 bf             	and    $0xffffffbf,%ecx
8010220f:	89 0d b8 95 12 80    	mov    %ecx,0x801295b8
  }

  shift |= shiftcode[data];
80102215:	0f b6 8a 40 69 10 80 	movzbl -0x7fef96c0(%edx),%ecx
8010221c:	0b 0d b8 95 12 80    	or     0x801295b8,%ecx
  shift ^= togglecode[data];
80102222:	0f b6 82 40 68 10 80 	movzbl -0x7fef97c0(%edx),%eax
80102229:	31 c1                	xor    %eax,%ecx
8010222b:	89 0d b8 95 12 80    	mov    %ecx,0x801295b8
  c = charcode[shift & (CTL | SHIFT)][data];
80102231:	89 c8                	mov    %ecx,%eax
80102233:	83 e0 03             	and    $0x3,%eax
80102236:	8b 04 85 20 68 10 80 	mov    -0x7fef97e0(,%eax,4),%eax
8010223d:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102241:	f6 c1 08             	test   $0x8,%cl
80102244:	74 19                	je     8010225f <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102246:	8d 50 9f             	lea    -0x61(%eax),%edx
80102249:	83 fa 19             	cmp    $0x19,%edx
8010224c:	77 40                	ja     8010228e <kbdgetc+0xb9>
      c += 'A' - 'a';
8010224e:	83 e8 20             	sub    $0x20,%eax
80102251:	eb 0c                	jmp    8010225f <kbdgetc+0x8a>
    shift |= E0ESC;
80102253:	83 0d b8 95 12 80 40 	orl    $0x40,0x801295b8
    return 0;
8010225a:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010225f:	5d                   	pop    %ebp
80102260:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102261:	8b 0d b8 95 12 80    	mov    0x801295b8,%ecx
80102267:	f6 c1 40             	test   $0x40,%cl
8010226a:	75 05                	jne    80102271 <kbdgetc+0x9c>
8010226c:	89 c2                	mov    %eax,%edx
8010226e:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102271:	0f b6 82 40 69 10 80 	movzbl -0x7fef96c0(%edx),%eax
80102278:	83 c8 40             	or     $0x40,%eax
8010227b:	0f b6 c0             	movzbl %al,%eax
8010227e:	f7 d0                	not    %eax
80102280:	21 c8                	and    %ecx,%eax
80102282:	a3 b8 95 12 80       	mov    %eax,0x801295b8
    return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
8010228c:	eb d1                	jmp    8010225f <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010228e:	8d 50 bf             	lea    -0x41(%eax),%edx
80102291:	83 fa 19             	cmp    $0x19,%edx
80102294:	77 c9                	ja     8010225f <kbdgetc+0x8a>
      c += 'a' - 'A';
80102296:	83 c0 20             	add    $0x20,%eax
  return c;
80102299:	eb c4                	jmp    8010225f <kbdgetc+0x8a>
    return -1;
8010229b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a0:	eb bd                	jmp    8010225f <kbdgetc+0x8a>

801022a2 <kbdintr>:

void
kbdintr(void)
{
801022a2:	55                   	push   %ebp
801022a3:	89 e5                	mov    %esp,%ebp
801022a5:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801022a8:	68 d5 21 10 80       	push   $0x801021d5
801022ad:	e8 8c e4 ff ff       	call   8010073e <consoleintr>
}
801022b2:	83 c4 10             	add    $0x10,%esp
801022b5:	c9                   	leave  
801022b6:	c3                   	ret    

801022b7 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801022b7:	55                   	push   %ebp
801022b8:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801022ba:	8b 0d 9c 16 13 80    	mov    0x8013169c,%ecx
801022c0:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022c3:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801022c5:	a1 9c 16 13 80       	mov    0x8013169c,%eax
801022ca:	8b 40 20             	mov    0x20(%eax),%eax
}
801022cd:	5d                   	pop    %ebp
801022ce:	c3                   	ret    

801022cf <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801022cf:	55                   	push   %ebp
801022d0:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801022d2:	ba 70 00 00 00       	mov    $0x70,%edx
801022d7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022d8:	ba 71 00 00 00       	mov    $0x71,%edx
801022dd:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801022de:	0f b6 c0             	movzbl %al,%eax
}
801022e1:	5d                   	pop    %ebp
801022e2:	c3                   	ret    

801022e3 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801022e3:	55                   	push   %ebp
801022e4:	89 e5                	mov    %esp,%ebp
801022e6:	53                   	push   %ebx
801022e7:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801022e9:	b8 00 00 00 00       	mov    $0x0,%eax
801022ee:	e8 dc ff ff ff       	call   801022cf <cmos_read>
801022f3:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801022f5:	b8 02 00 00 00       	mov    $0x2,%eax
801022fa:	e8 d0 ff ff ff       	call   801022cf <cmos_read>
801022ff:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102302:	b8 04 00 00 00       	mov    $0x4,%eax
80102307:	e8 c3 ff ff ff       	call   801022cf <cmos_read>
8010230c:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010230f:	b8 07 00 00 00       	mov    $0x7,%eax
80102314:	e8 b6 ff ff ff       	call   801022cf <cmos_read>
80102319:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
8010231c:	b8 08 00 00 00       	mov    $0x8,%eax
80102321:	e8 a9 ff ff ff       	call   801022cf <cmos_read>
80102326:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102329:	b8 09 00 00 00       	mov    $0x9,%eax
8010232e:	e8 9c ff ff ff       	call   801022cf <cmos_read>
80102333:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102336:	5b                   	pop    %ebx
80102337:	5d                   	pop    %ebp
80102338:	c3                   	ret    

80102339 <lapicinit>:
  if(!lapic)
80102339:	83 3d 9c 16 13 80 00 	cmpl   $0x0,0x8013169c
80102340:	0f 84 fb 00 00 00    	je     80102441 <lapicinit+0x108>
{
80102346:	55                   	push   %ebp
80102347:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102349:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010234e:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102353:	e8 5f ff ff ff       	call   801022b7 <lapicw>
  lapicw(TDCR, X1);
80102358:	ba 0b 00 00 00       	mov    $0xb,%edx
8010235d:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102362:	e8 50 ff ff ff       	call   801022b7 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102367:	ba 20 00 02 00       	mov    $0x20020,%edx
8010236c:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102371:	e8 41 ff ff ff       	call   801022b7 <lapicw>
  lapicw(TICR, 10000000);
80102376:	ba 80 96 98 00       	mov    $0x989680,%edx
8010237b:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102380:	e8 32 ff ff ff       	call   801022b7 <lapicw>
  lapicw(LINT0, MASKED);
80102385:	ba 00 00 01 00       	mov    $0x10000,%edx
8010238a:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010238f:	e8 23 ff ff ff       	call   801022b7 <lapicw>
  lapicw(LINT1, MASKED);
80102394:	ba 00 00 01 00       	mov    $0x10000,%edx
80102399:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010239e:	e8 14 ff ff ff       	call   801022b7 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801023a3:	a1 9c 16 13 80       	mov    0x8013169c,%eax
801023a8:	8b 40 30             	mov    0x30(%eax),%eax
801023ab:	c1 e8 10             	shr    $0x10,%eax
801023ae:	3c 03                	cmp    $0x3,%al
801023b0:	77 7b                	ja     8010242d <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801023b2:	ba 33 00 00 00       	mov    $0x33,%edx
801023b7:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023bc:	e8 f6 fe ff ff       	call   801022b7 <lapicw>
  lapicw(ESR, 0);
801023c1:	ba 00 00 00 00       	mov    $0x0,%edx
801023c6:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023cb:	e8 e7 fe ff ff       	call   801022b7 <lapicw>
  lapicw(ESR, 0);
801023d0:	ba 00 00 00 00       	mov    $0x0,%edx
801023d5:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023da:	e8 d8 fe ff ff       	call   801022b7 <lapicw>
  lapicw(EOI, 0);
801023df:	ba 00 00 00 00       	mov    $0x0,%edx
801023e4:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023e9:	e8 c9 fe ff ff       	call   801022b7 <lapicw>
  lapicw(ICRHI, 0);
801023ee:	ba 00 00 00 00       	mov    $0x0,%edx
801023f3:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023f8:	e8 ba fe ff ff       	call   801022b7 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801023fd:	ba 00 85 08 00       	mov    $0x88500,%edx
80102402:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102407:	e8 ab fe ff ff       	call   801022b7 <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010240c:	a1 9c 16 13 80       	mov    0x8013169c,%eax
80102411:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102417:	f6 c4 10             	test   $0x10,%ah
8010241a:	75 f0                	jne    8010240c <lapicinit+0xd3>
  lapicw(TPR, 0);
8010241c:	ba 00 00 00 00       	mov    $0x0,%edx
80102421:	b8 20 00 00 00       	mov    $0x20,%eax
80102426:	e8 8c fe ff ff       	call   801022b7 <lapicw>
}
8010242b:	5d                   	pop    %ebp
8010242c:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010242d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102432:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102437:	e8 7b fe ff ff       	call   801022b7 <lapicw>
8010243c:	e9 71 ff ff ff       	jmp    801023b2 <lapicinit+0x79>
80102441:	f3 c3                	repz ret 

80102443 <lapicid>:
{
80102443:	55                   	push   %ebp
80102444:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102446:	a1 9c 16 13 80       	mov    0x8013169c,%eax
8010244b:	85 c0                	test   %eax,%eax
8010244d:	74 08                	je     80102457 <lapicid+0x14>
  return lapic[ID] >> 24;
8010244f:	8b 40 20             	mov    0x20(%eax),%eax
80102452:	c1 e8 18             	shr    $0x18,%eax
}
80102455:	5d                   	pop    %ebp
80102456:	c3                   	ret    
    return 0;
80102457:	b8 00 00 00 00       	mov    $0x0,%eax
8010245c:	eb f7                	jmp    80102455 <lapicid+0x12>

8010245e <lapiceoi>:
  if(lapic)
8010245e:	83 3d 9c 16 13 80 00 	cmpl   $0x0,0x8013169c
80102465:	74 14                	je     8010247b <lapiceoi+0x1d>
{
80102467:	55                   	push   %ebp
80102468:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
8010246a:	ba 00 00 00 00       	mov    $0x0,%edx
8010246f:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102474:	e8 3e fe ff ff       	call   801022b7 <lapicw>
}
80102479:	5d                   	pop    %ebp
8010247a:	c3                   	ret    
8010247b:	f3 c3                	repz ret 

8010247d <microdelay>:
{
8010247d:	55                   	push   %ebp
8010247e:	89 e5                	mov    %esp,%ebp
}
80102480:	5d                   	pop    %ebp
80102481:	c3                   	ret    

80102482 <lapicstartap>:
{
80102482:	55                   	push   %ebp
80102483:	89 e5                	mov    %esp,%ebp
80102485:	57                   	push   %edi
80102486:	56                   	push   %esi
80102487:	53                   	push   %ebx
80102488:	8b 75 08             	mov    0x8(%ebp),%esi
8010248b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010248e:	b8 0f 00 00 00       	mov    $0xf,%eax
80102493:	ba 70 00 00 00       	mov    $0x70,%edx
80102498:	ee                   	out    %al,(%dx)
80102499:	b8 0a 00 00 00       	mov    $0xa,%eax
8010249e:	ba 71 00 00 00       	mov    $0x71,%edx
801024a3:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801024a4:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801024ab:	00 00 
  wrv[1] = addr >> 4;
801024ad:	89 f8                	mov    %edi,%eax
801024af:	c1 e8 04             	shr    $0x4,%eax
801024b2:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801024b8:	c1 e6 18             	shl    $0x18,%esi
801024bb:	89 f2                	mov    %esi,%edx
801024bd:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024c2:	e8 f0 fd ff ff       	call   801022b7 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801024c7:	ba 00 c5 00 00       	mov    $0xc500,%edx
801024cc:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024d1:	e8 e1 fd ff ff       	call   801022b7 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801024d6:	ba 00 85 00 00       	mov    $0x8500,%edx
801024db:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024e0:	e8 d2 fd ff ff       	call   801022b7 <lapicw>
  for(i = 0; i < 2; i++){
801024e5:	bb 00 00 00 00       	mov    $0x0,%ebx
801024ea:	eb 21                	jmp    8010250d <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801024ec:	89 f2                	mov    %esi,%edx
801024ee:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024f3:	e8 bf fd ff ff       	call   801022b7 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801024f8:	89 fa                	mov    %edi,%edx
801024fa:	c1 ea 0c             	shr    $0xc,%edx
801024fd:	80 ce 06             	or     $0x6,%dh
80102500:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102505:	e8 ad fd ff ff       	call   801022b7 <lapicw>
  for(i = 0; i < 2; i++){
8010250a:	83 c3 01             	add    $0x1,%ebx
8010250d:	83 fb 01             	cmp    $0x1,%ebx
80102510:	7e da                	jle    801024ec <lapicstartap+0x6a>
}
80102512:	5b                   	pop    %ebx
80102513:	5e                   	pop    %esi
80102514:	5f                   	pop    %edi
80102515:	5d                   	pop    %ebp
80102516:	c3                   	ret    

80102517 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102517:	55                   	push   %ebp
80102518:	89 e5                	mov    %esp,%ebp
8010251a:	57                   	push   %edi
8010251b:	56                   	push   %esi
8010251c:	53                   	push   %ebx
8010251d:	83 ec 3c             	sub    $0x3c,%esp
80102520:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102523:	b8 0b 00 00 00       	mov    $0xb,%eax
80102528:	e8 a2 fd ff ff       	call   801022cf <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010252d:	83 e0 04             	and    $0x4,%eax
80102530:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102532:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102535:	e8 a9 fd ff ff       	call   801022e3 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010253a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010253f:	e8 8b fd ff ff       	call   801022cf <cmos_read>
80102544:	a8 80                	test   $0x80,%al
80102546:	75 ea                	jne    80102532 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102548:	8d 5d b8             	lea    -0x48(%ebp),%ebx
8010254b:	89 d8                	mov    %ebx,%eax
8010254d:	e8 91 fd ff ff       	call   801022e3 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102552:	83 ec 04             	sub    $0x4,%esp
80102555:	6a 18                	push   $0x18
80102557:	53                   	push   %ebx
80102558:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010255b:	50                   	push   %eax
8010255c:	e8 01 18 00 00       	call   80103d62 <memcmp>
80102561:	83 c4 10             	add    $0x10,%esp
80102564:	85 c0                	test   %eax,%eax
80102566:	75 ca                	jne    80102532 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102568:	85 ff                	test   %edi,%edi
8010256a:	0f 85 84 00 00 00    	jne    801025f4 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102570:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102573:	89 d0                	mov    %edx,%eax
80102575:	c1 e8 04             	shr    $0x4,%eax
80102578:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010257b:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010257e:	83 e2 0f             	and    $0xf,%edx
80102581:	01 d0                	add    %edx,%eax
80102583:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102586:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102589:	89 d0                	mov    %edx,%eax
8010258b:	c1 e8 04             	shr    $0x4,%eax
8010258e:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102591:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102594:	83 e2 0f             	and    $0xf,%edx
80102597:	01 d0                	add    %edx,%eax
80102599:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010259c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010259f:	89 d0                	mov    %edx,%eax
801025a1:	c1 e8 04             	shr    $0x4,%eax
801025a4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025a7:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025aa:	83 e2 0f             	and    $0xf,%edx
801025ad:	01 d0                	add    %edx,%eax
801025af:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801025b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801025b5:	89 d0                	mov    %edx,%eax
801025b7:	c1 e8 04             	shr    $0x4,%eax
801025ba:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025bd:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025c0:	83 e2 0f             	and    $0xf,%edx
801025c3:	01 d0                	add    %edx,%eax
801025c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801025c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801025cb:	89 d0                	mov    %edx,%eax
801025cd:	c1 e8 04             	shr    $0x4,%eax
801025d0:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025d3:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025d6:	83 e2 0f             	and    $0xf,%edx
801025d9:	01 d0                	add    %edx,%eax
801025db:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801025de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801025e1:	89 d0                	mov    %edx,%eax
801025e3:	c1 e8 04             	shr    $0x4,%eax
801025e6:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025e9:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025ec:	83 e2 0f             	and    $0xf,%edx
801025ef:	01 d0                	add    %edx,%eax
801025f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801025f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801025f7:	89 06                	mov    %eax,(%esi)
801025f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801025fc:	89 46 04             	mov    %eax,0x4(%esi)
801025ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102602:	89 46 08             	mov    %eax,0x8(%esi)
80102605:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102608:	89 46 0c             	mov    %eax,0xc(%esi)
8010260b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010260e:	89 46 10             	mov    %eax,0x10(%esi)
80102611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102614:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102617:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010261e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102621:	5b                   	pop    %ebx
80102622:	5e                   	pop    %esi
80102623:	5f                   	pop    %edi
80102624:	5d                   	pop    %ebp
80102625:	c3                   	ret    

80102626 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102626:	55                   	push   %ebp
80102627:	89 e5                	mov    %esp,%ebp
80102629:	53                   	push   %ebx
8010262a:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010262d:	ff 35 d4 16 13 80    	pushl  0x801316d4
80102633:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102639:	e8 2e db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010263e:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102641:	89 1d e8 16 13 80    	mov    %ebx,0x801316e8
  for (i = 0; i < log.lh.n; i++) {
80102647:	83 c4 10             	add    $0x10,%esp
8010264a:	ba 00 00 00 00       	mov    $0x0,%edx
8010264f:	eb 0e                	jmp    8010265f <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102651:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102655:	89 0c 95 ec 16 13 80 	mov    %ecx,-0x7fece914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010265c:	83 c2 01             	add    $0x1,%edx
8010265f:	39 d3                	cmp    %edx,%ebx
80102661:	7f ee                	jg     80102651 <read_head+0x2b>
  }
  brelse(buf);
80102663:	83 ec 0c             	sub    $0xc,%esp
80102666:	50                   	push   %eax
80102667:	e8 69 db ff ff       	call   801001d5 <brelse>
}
8010266c:	83 c4 10             	add    $0x10,%esp
8010266f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102672:	c9                   	leave  
80102673:	c3                   	ret    

80102674 <install_trans>:
{
80102674:	55                   	push   %ebp
80102675:	89 e5                	mov    %esp,%ebp
80102677:	57                   	push   %edi
80102678:	56                   	push   %esi
80102679:	53                   	push   %ebx
8010267a:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010267d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102682:	eb 66                	jmp    801026ea <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102684:	89 d8                	mov    %ebx,%eax
80102686:	03 05 d4 16 13 80    	add    0x801316d4,%eax
8010268c:	83 c0 01             	add    $0x1,%eax
8010268f:	83 ec 08             	sub    $0x8,%esp
80102692:	50                   	push   %eax
80102693:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102699:	e8 ce da ff ff       	call   8010016c <bread>
8010269e:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801026a0:	83 c4 08             	add    $0x8,%esp
801026a3:	ff 34 9d ec 16 13 80 	pushl  -0x7fece914(,%ebx,4)
801026aa:	ff 35 e4 16 13 80    	pushl  0x801316e4
801026b0:	e8 b7 da ff ff       	call   8010016c <bread>
801026b5:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801026b7:	8d 57 5c             	lea    0x5c(%edi),%edx
801026ba:	8d 40 5c             	lea    0x5c(%eax),%eax
801026bd:	83 c4 0c             	add    $0xc,%esp
801026c0:	68 00 02 00 00       	push   $0x200
801026c5:	52                   	push   %edx
801026c6:	50                   	push   %eax
801026c7:	e8 cb 16 00 00       	call   80103d97 <memmove>
    bwrite(dbuf);  // write dst to disk
801026cc:	89 34 24             	mov    %esi,(%esp)
801026cf:	e8 c6 da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801026d4:	89 3c 24             	mov    %edi,(%esp)
801026d7:	e8 f9 da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801026dc:	89 34 24             	mov    %esi,(%esp)
801026df:	e8 f1 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801026e4:	83 c3 01             	add    $0x1,%ebx
801026e7:	83 c4 10             	add    $0x10,%esp
801026ea:	39 1d e8 16 13 80    	cmp    %ebx,0x801316e8
801026f0:	7f 92                	jg     80102684 <install_trans+0x10>
}
801026f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026f5:	5b                   	pop    %ebx
801026f6:	5e                   	pop    %esi
801026f7:	5f                   	pop    %edi
801026f8:	5d                   	pop    %ebp
801026f9:	c3                   	ret    

801026fa <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801026fa:	55                   	push   %ebp
801026fb:	89 e5                	mov    %esp,%ebp
801026fd:	53                   	push   %ebx
801026fe:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102701:	ff 35 d4 16 13 80    	pushl  0x801316d4
80102707:	ff 35 e4 16 13 80    	pushl  0x801316e4
8010270d:	e8 5a da ff ff       	call   8010016c <bread>
80102712:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102714:	8b 0d e8 16 13 80    	mov    0x801316e8,%ecx
8010271a:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010271d:	83 c4 10             	add    $0x10,%esp
80102720:	b8 00 00 00 00       	mov    $0x0,%eax
80102725:	eb 0e                	jmp    80102735 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102727:	8b 14 85 ec 16 13 80 	mov    -0x7fece914(,%eax,4),%edx
8010272e:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102732:	83 c0 01             	add    $0x1,%eax
80102735:	39 c1                	cmp    %eax,%ecx
80102737:	7f ee                	jg     80102727 <write_head+0x2d>
  }
  bwrite(buf);
80102739:	83 ec 0c             	sub    $0xc,%esp
8010273c:	53                   	push   %ebx
8010273d:	e8 58 da ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102742:	89 1c 24             	mov    %ebx,(%esp)
80102745:	e8 8b da ff ff       	call   801001d5 <brelse>
}
8010274a:	83 c4 10             	add    $0x10,%esp
8010274d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102750:	c9                   	leave  
80102751:	c3                   	ret    

80102752 <recover_from_log>:

static void
recover_from_log(void)
{
80102752:	55                   	push   %ebp
80102753:	89 e5                	mov    %esp,%ebp
80102755:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102758:	e8 c9 fe ff ff       	call   80102626 <read_head>
  install_trans(); // if committed, copy from log to disk
8010275d:	e8 12 ff ff ff       	call   80102674 <install_trans>
  log.lh.n = 0;
80102762:	c7 05 e8 16 13 80 00 	movl   $0x0,0x801316e8
80102769:	00 00 00 
  write_head(); // clear the log
8010276c:	e8 89 ff ff ff       	call   801026fa <write_head>
}
80102771:	c9                   	leave  
80102772:	c3                   	ret    

80102773 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102773:	55                   	push   %ebp
80102774:	89 e5                	mov    %esp,%ebp
80102776:	57                   	push   %edi
80102777:	56                   	push   %esi
80102778:	53                   	push   %ebx
80102779:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010277c:	bb 00 00 00 00       	mov    $0x0,%ebx
80102781:	eb 66                	jmp    801027e9 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102783:	89 d8                	mov    %ebx,%eax
80102785:	03 05 d4 16 13 80    	add    0x801316d4,%eax
8010278b:	83 c0 01             	add    $0x1,%eax
8010278e:	83 ec 08             	sub    $0x8,%esp
80102791:	50                   	push   %eax
80102792:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102798:	e8 cf d9 ff ff       	call   8010016c <bread>
8010279d:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010279f:	83 c4 08             	add    $0x8,%esp
801027a2:	ff 34 9d ec 16 13 80 	pushl  -0x7fece914(,%ebx,4)
801027a9:	ff 35 e4 16 13 80    	pushl  0x801316e4
801027af:	e8 b8 d9 ff ff       	call   8010016c <bread>
801027b4:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801027b6:	8d 50 5c             	lea    0x5c(%eax),%edx
801027b9:	8d 46 5c             	lea    0x5c(%esi),%eax
801027bc:	83 c4 0c             	add    $0xc,%esp
801027bf:	68 00 02 00 00       	push   $0x200
801027c4:	52                   	push   %edx
801027c5:	50                   	push   %eax
801027c6:	e8 cc 15 00 00       	call   80103d97 <memmove>
    bwrite(to);  // write the log
801027cb:	89 34 24             	mov    %esi,(%esp)
801027ce:	e8 c7 d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
801027d3:	89 3c 24             	mov    %edi,(%esp)
801027d6:	e8 fa d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
801027db:	89 34 24             	mov    %esi,(%esp)
801027de:	e8 f2 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027e3:	83 c3 01             	add    $0x1,%ebx
801027e6:	83 c4 10             	add    $0x10,%esp
801027e9:	39 1d e8 16 13 80    	cmp    %ebx,0x801316e8
801027ef:	7f 92                	jg     80102783 <write_log+0x10>
  }
}
801027f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027f4:	5b                   	pop    %ebx
801027f5:	5e                   	pop    %esi
801027f6:	5f                   	pop    %edi
801027f7:	5d                   	pop    %ebp
801027f8:	c3                   	ret    

801027f9 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801027f9:	83 3d e8 16 13 80 00 	cmpl   $0x0,0x801316e8
80102800:	7e 26                	jle    80102828 <commit+0x2f>
{
80102802:	55                   	push   %ebp
80102803:	89 e5                	mov    %esp,%ebp
80102805:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102808:	e8 66 ff ff ff       	call   80102773 <write_log>
    write_head();    // Write header to disk -- the real commit
8010280d:	e8 e8 fe ff ff       	call   801026fa <write_head>
    install_trans(); // Now install writes to home locations
80102812:	e8 5d fe ff ff       	call   80102674 <install_trans>
    log.lh.n = 0;
80102817:	c7 05 e8 16 13 80 00 	movl   $0x0,0x801316e8
8010281e:	00 00 00 
    write_head();    // Erase the transaction from the log
80102821:	e8 d4 fe ff ff       	call   801026fa <write_head>
  }
}
80102826:	c9                   	leave  
80102827:	c3                   	ret    
80102828:	f3 c3                	repz ret 

8010282a <initlog>:
{
8010282a:	55                   	push   %ebp
8010282b:	89 e5                	mov    %esp,%ebp
8010282d:	53                   	push   %ebx
8010282e:	83 ec 2c             	sub    $0x2c,%esp
80102831:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102834:	68 40 6a 10 80       	push   $0x80106a40
80102839:	68 a0 16 13 80       	push   $0x801316a0
8010283e:	e8 f1 12 00 00       	call   80103b34 <initlock>
  readsb(dev, &sb);
80102843:	83 c4 08             	add    $0x8,%esp
80102846:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102849:	50                   	push   %eax
8010284a:	53                   	push   %ebx
8010284b:	e8 f2 e9 ff ff       	call   80101242 <readsb>
  log.start = sb.logstart;
80102850:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102853:	a3 d4 16 13 80       	mov    %eax,0x801316d4
  log.size = sb.nlog;
80102858:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010285b:	a3 d8 16 13 80       	mov    %eax,0x801316d8
  log.dev = dev;
80102860:	89 1d e4 16 13 80    	mov    %ebx,0x801316e4
  recover_from_log();
80102866:	e8 e7 fe ff ff       	call   80102752 <recover_from_log>
}
8010286b:	83 c4 10             	add    $0x10,%esp
8010286e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102871:	c9                   	leave  
80102872:	c3                   	ret    

80102873 <begin_op>:
{
80102873:	55                   	push   %ebp
80102874:	89 e5                	mov    %esp,%ebp
80102876:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102879:	68 a0 16 13 80       	push   $0x801316a0
8010287e:	e8 ed 13 00 00       	call   80103c70 <acquire>
80102883:	83 c4 10             	add    $0x10,%esp
80102886:	eb 15                	jmp    8010289d <begin_op+0x2a>
      sleep(&log, &log.lock);
80102888:	83 ec 08             	sub    $0x8,%esp
8010288b:	68 a0 16 13 80       	push   $0x801316a0
80102890:	68 a0 16 13 80       	push   $0x801316a0
80102895:	e8 db 0e 00 00       	call   80103775 <sleep>
8010289a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010289d:	83 3d e0 16 13 80 00 	cmpl   $0x0,0x801316e0
801028a4:	75 e2                	jne    80102888 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801028a6:	a1 dc 16 13 80       	mov    0x801316dc,%eax
801028ab:	83 c0 01             	add    $0x1,%eax
801028ae:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801028b1:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801028b4:	03 15 e8 16 13 80    	add    0x801316e8,%edx
801028ba:	83 fa 1e             	cmp    $0x1e,%edx
801028bd:	7e 17                	jle    801028d6 <begin_op+0x63>
      sleep(&log, &log.lock);
801028bf:	83 ec 08             	sub    $0x8,%esp
801028c2:	68 a0 16 13 80       	push   $0x801316a0
801028c7:	68 a0 16 13 80       	push   $0x801316a0
801028cc:	e8 a4 0e 00 00       	call   80103775 <sleep>
801028d1:	83 c4 10             	add    $0x10,%esp
801028d4:	eb c7                	jmp    8010289d <begin_op+0x2a>
      log.outstanding += 1;
801028d6:	a3 dc 16 13 80       	mov    %eax,0x801316dc
      release(&log.lock);
801028db:	83 ec 0c             	sub    $0xc,%esp
801028de:	68 a0 16 13 80       	push   $0x801316a0
801028e3:	e8 ed 13 00 00       	call   80103cd5 <release>
}
801028e8:	83 c4 10             	add    $0x10,%esp
801028eb:	c9                   	leave  
801028ec:	c3                   	ret    

801028ed <end_op>:
{
801028ed:	55                   	push   %ebp
801028ee:	89 e5                	mov    %esp,%ebp
801028f0:	53                   	push   %ebx
801028f1:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801028f4:	68 a0 16 13 80       	push   $0x801316a0
801028f9:	e8 72 13 00 00       	call   80103c70 <acquire>
  log.outstanding -= 1;
801028fe:	a1 dc 16 13 80       	mov    0x801316dc,%eax
80102903:	83 e8 01             	sub    $0x1,%eax
80102906:	a3 dc 16 13 80       	mov    %eax,0x801316dc
  if(log.committing)
8010290b:	8b 1d e0 16 13 80    	mov    0x801316e0,%ebx
80102911:	83 c4 10             	add    $0x10,%esp
80102914:	85 db                	test   %ebx,%ebx
80102916:	75 2c                	jne    80102944 <end_op+0x57>
  if(log.outstanding == 0){
80102918:	85 c0                	test   %eax,%eax
8010291a:	75 35                	jne    80102951 <end_op+0x64>
    log.committing = 1;
8010291c:	c7 05 e0 16 13 80 01 	movl   $0x1,0x801316e0
80102923:	00 00 00 
    do_commit = 1;
80102926:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
8010292b:	83 ec 0c             	sub    $0xc,%esp
8010292e:	68 a0 16 13 80       	push   $0x801316a0
80102933:	e8 9d 13 00 00       	call   80103cd5 <release>
  if(do_commit){
80102938:	83 c4 10             	add    $0x10,%esp
8010293b:	85 db                	test   %ebx,%ebx
8010293d:	75 24                	jne    80102963 <end_op+0x76>
}
8010293f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102942:	c9                   	leave  
80102943:	c3                   	ret    
    panic("log.committing");
80102944:	83 ec 0c             	sub    $0xc,%esp
80102947:	68 44 6a 10 80       	push   $0x80106a44
8010294c:	e8 f7 d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102951:	83 ec 0c             	sub    $0xc,%esp
80102954:	68 a0 16 13 80       	push   $0x801316a0
80102959:	e8 7c 0f 00 00       	call   801038da <wakeup>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	eb c8                	jmp    8010292b <end_op+0x3e>
    commit();
80102963:	e8 91 fe ff ff       	call   801027f9 <commit>
    acquire(&log.lock);
80102968:	83 ec 0c             	sub    $0xc,%esp
8010296b:	68 a0 16 13 80       	push   $0x801316a0
80102970:	e8 fb 12 00 00       	call   80103c70 <acquire>
    log.committing = 0;
80102975:	c7 05 e0 16 13 80 00 	movl   $0x0,0x801316e0
8010297c:	00 00 00 
    wakeup(&log);
8010297f:	c7 04 24 a0 16 13 80 	movl   $0x801316a0,(%esp)
80102986:	e8 4f 0f 00 00       	call   801038da <wakeup>
    release(&log.lock);
8010298b:	c7 04 24 a0 16 13 80 	movl   $0x801316a0,(%esp)
80102992:	e8 3e 13 00 00       	call   80103cd5 <release>
80102997:	83 c4 10             	add    $0x10,%esp
}
8010299a:	eb a3                	jmp    8010293f <end_op+0x52>

8010299c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010299c:	55                   	push   %ebp
8010299d:	89 e5                	mov    %esp,%ebp
8010299f:	53                   	push   %ebx
801029a0:	83 ec 04             	sub    $0x4,%esp
801029a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801029a6:	8b 15 e8 16 13 80    	mov    0x801316e8,%edx
801029ac:	83 fa 1d             	cmp    $0x1d,%edx
801029af:	7f 45                	jg     801029f6 <log_write+0x5a>
801029b1:	a1 d8 16 13 80       	mov    0x801316d8,%eax
801029b6:	83 e8 01             	sub    $0x1,%eax
801029b9:	39 c2                	cmp    %eax,%edx
801029bb:	7d 39                	jge    801029f6 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
801029bd:	83 3d dc 16 13 80 00 	cmpl   $0x0,0x801316dc
801029c4:	7e 3d                	jle    80102a03 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
801029c6:	83 ec 0c             	sub    $0xc,%esp
801029c9:	68 a0 16 13 80       	push   $0x801316a0
801029ce:	e8 9d 12 00 00       	call   80103c70 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029d3:	83 c4 10             	add    $0x10,%esp
801029d6:	b8 00 00 00 00       	mov    $0x0,%eax
801029db:	8b 15 e8 16 13 80    	mov    0x801316e8,%edx
801029e1:	39 c2                	cmp    %eax,%edx
801029e3:	7e 2b                	jle    80102a10 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029e5:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029e8:	39 0c 85 ec 16 13 80 	cmp    %ecx,-0x7fece914(,%eax,4)
801029ef:	74 1f                	je     80102a10 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
801029f1:	83 c0 01             	add    $0x1,%eax
801029f4:	eb e5                	jmp    801029db <log_write+0x3f>
    panic("too big a transaction");
801029f6:	83 ec 0c             	sub    $0xc,%esp
801029f9:	68 53 6a 10 80       	push   $0x80106a53
801029fe:	e8 45 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102a03:	83 ec 0c             	sub    $0xc,%esp
80102a06:	68 69 6a 10 80       	push   $0x80106a69
80102a0b:	e8 38 d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102a10:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a13:	89 0c 85 ec 16 13 80 	mov    %ecx,-0x7fece914(,%eax,4)
  if (i == log.lh.n)
80102a1a:	39 c2                	cmp    %eax,%edx
80102a1c:	74 18                	je     80102a36 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102a1e:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102a21:	83 ec 0c             	sub    $0xc,%esp
80102a24:	68 a0 16 13 80       	push   $0x801316a0
80102a29:	e8 a7 12 00 00       	call   80103cd5 <release>
}
80102a2e:	83 c4 10             	add    $0x10,%esp
80102a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a34:	c9                   	leave  
80102a35:	c3                   	ret    
    log.lh.n++;
80102a36:	83 c2 01             	add    $0x1,%edx
80102a39:	89 15 e8 16 13 80    	mov    %edx,0x801316e8
80102a3f:	eb dd                	jmp    80102a1e <log_write+0x82>

80102a41 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102a41:	55                   	push   %ebp
80102a42:	89 e5                	mov    %esp,%ebp
80102a44:	53                   	push   %ebx
80102a45:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102a48:	68 8a 00 00 00       	push   $0x8a
80102a4d:	68 8c 94 12 80       	push   $0x8012948c
80102a52:	68 00 70 00 80       	push   $0x80007000
80102a57:	e8 3b 13 00 00       	call   80103d97 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102a5c:	83 c4 10             	add    $0x10,%esp
80102a5f:	bb a0 17 13 80       	mov    $0x801317a0,%ebx
80102a64:	eb 06                	jmp    80102a6c <startothers+0x2b>
80102a66:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102a6c:	69 05 20 1d 13 80 b0 	imul   $0xb0,0x80131d20,%eax
80102a73:	00 00 00 
80102a76:	05 a0 17 13 80       	add    $0x801317a0,%eax
80102a7b:	39 d8                	cmp    %ebx,%eax
80102a7d:	76 51                	jbe    80102ad0 <startothers+0x8f>
    if(c == mycpu())  // We've started already.
80102a7f:	e8 d3 07 00 00       	call   80103257 <mycpu>
80102a84:	39 d8                	cmp    %ebx,%eax
80102a86:	74 de                	je     80102a66 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc(-2);
80102a88:	83 ec 0c             	sub    $0xc,%esp
80102a8b:	6a fe                	push   $0xfffffffe
80102a8d:	e8 35 f6 ff ff       	call   801020c7 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102a92:	05 00 10 00 00       	add    $0x1000,%eax
80102a97:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102a9c:	c7 05 f8 6f 00 80 14 	movl   $0x80102b14,0x80006ff8
80102aa3:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102aa6:	c7 05 f4 6f 00 80 00 	movl   $0x128000,0x80006ff4
80102aad:	80 12 00 

    lapicstartap(c->apicid, V2P(code));
80102ab0:	83 c4 08             	add    $0x8,%esp
80102ab3:	68 00 70 00 00       	push   $0x7000
80102ab8:	0f b6 03             	movzbl (%ebx),%eax
80102abb:	50                   	push   %eax
80102abc:	e8 c1 f9 ff ff       	call   80102482 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102ac1:	83 c4 10             	add    $0x10,%esp
80102ac4:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102aca:	85 c0                	test   %eax,%eax
80102acc:	74 f6                	je     80102ac4 <startothers+0x83>
80102ace:	eb 96                	jmp    80102a66 <startothers+0x25>
      ;
  }
}
80102ad0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ad3:	c9                   	leave  
80102ad4:	c3                   	ret    

80102ad5 <mpmain>:
{
80102ad5:	55                   	push   %ebp
80102ad6:	89 e5                	mov    %esp,%ebp
80102ad8:	53                   	push   %ebx
80102ad9:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102adc:	e8 d2 07 00 00       	call   801032b3 <cpuid>
80102ae1:	89 c3                	mov    %eax,%ebx
80102ae3:	e8 cb 07 00 00       	call   801032b3 <cpuid>
80102ae8:	83 ec 04             	sub    $0x4,%esp
80102aeb:	53                   	push   %ebx
80102aec:	50                   	push   %eax
80102aed:	68 84 6a 10 80       	push   $0x80106a84
80102af2:	e8 14 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102af7:	e8 f2 23 00 00       	call   80104eee <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102afc:	e8 56 07 00 00       	call   80103257 <mycpu>
80102b01:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102b03:	b8 01 00 00 00       	mov    $0x1,%eax
80102b08:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102b0f:	e8 3c 0a 00 00       	call   80103550 <scheduler>

80102b14 <mpenter>:
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b1a:	e8 e0 33 00 00       	call   80105eff <switchkvm>
  seginit();
80102b1f:	e8 8f 32 00 00       	call   80105db3 <seginit>
  lapicinit();
80102b24:	e8 10 f8 ff ff       	call   80102339 <lapicinit>
  mpmain();
80102b29:	e8 a7 ff ff ff       	call   80102ad5 <mpmain>

80102b2e <main>:
{
80102b2e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102b32:	83 e4 f0             	and    $0xfffffff0,%esp
80102b35:	ff 71 fc             	pushl  -0x4(%ecx)
80102b38:	55                   	push   %ebp
80102b39:	89 e5                	mov    %esp,%ebp
80102b3b:	51                   	push   %ecx
80102b3c:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b3f:	68 00 00 40 80       	push   $0x80400000
80102b44:	68 c8 44 13 80       	push   $0x801344c8
80102b49:	e8 27 f5 ff ff       	call   80102075 <kinit1>
  kvmalloc();      // kernel page table
80102b4e:	e8 4f 38 00 00       	call   801063a2 <kvmalloc>
  mpinit();        // detect other processors
80102b53:	e8 c9 01 00 00       	call   80102d21 <mpinit>
  lapicinit();     // interrupt controller
80102b58:	e8 dc f7 ff ff       	call   80102339 <lapicinit>
  seginit();       // segment descriptors
80102b5d:	e8 51 32 00 00       	call   80105db3 <seginit>
  picinit();       // disable pic
80102b62:	e8 82 02 00 00       	call   80102de9 <picinit>
  ioapicinit();    // another interrupt controller
80102b67:	e8 9a f3 ff ff       	call   80101f06 <ioapicinit>
  consoleinit();   // console hardware
80102b6c:	e8 1d dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102b71:	e8 26 26 00 00       	call   8010519c <uartinit>
  pinit();         // process table
80102b76:	e8 c2 06 00 00       	call   8010323d <pinit>
  tvinit();        // trap vectors
80102b7b:	e8 bd 22 00 00       	call   80104e3d <tvinit>
  binit();         // buffer cache
80102b80:	e8 6f d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102b85:	e8 95 e0 ff ff       	call   80100c1f <fileinit>
  ideinit();       // disk 
80102b8a:	e8 7d f1 ff ff       	call   80101d0c <ideinit>
  startothers();   // start other processors
80102b8f:	e8 ad fe ff ff       	call   80102a41 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b94:	83 c4 08             	add    $0x8,%esp
80102b97:	68 00 00 00 8e       	push   $0x8e000000
80102b9c:	68 00 00 40 80       	push   $0x80400000
80102ba1:	e8 01 f5 ff ff       	call   801020a7 <kinit2>
  userinit();      // first user process
80102ba6:	e8 47 07 00 00       	call   801032f2 <userinit>
  mpmain();        // finish this processor's setup
80102bab:	e8 25 ff ff ff       	call   80102ad5 <mpmain>

80102bb0 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102bb0:	55                   	push   %ebp
80102bb1:	89 e5                	mov    %esp,%ebp
80102bb3:	56                   	push   %esi
80102bb4:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102bba:	b9 00 00 00 00       	mov    $0x0,%ecx
80102bbf:	eb 09                	jmp    80102bca <sum+0x1a>
    sum += addr[i];
80102bc1:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102bc5:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102bc7:	83 c1 01             	add    $0x1,%ecx
80102bca:	39 d1                	cmp    %edx,%ecx
80102bcc:	7c f3                	jl     80102bc1 <sum+0x11>
  return sum;
}
80102bce:	89 d8                	mov    %ebx,%eax
80102bd0:	5b                   	pop    %ebx
80102bd1:	5e                   	pop    %esi
80102bd2:	5d                   	pop    %ebp
80102bd3:	c3                   	ret    

80102bd4 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102bd4:	55                   	push   %ebp
80102bd5:	89 e5                	mov    %esp,%ebp
80102bd7:	56                   	push   %esi
80102bd8:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102bd9:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102bdf:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102be1:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102be3:	eb 03                	jmp    80102be8 <mpsearch1+0x14>
80102be5:	83 c3 10             	add    $0x10,%ebx
80102be8:	39 f3                	cmp    %esi,%ebx
80102bea:	73 29                	jae    80102c15 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102bec:	83 ec 04             	sub    $0x4,%esp
80102bef:	6a 04                	push   $0x4
80102bf1:	68 98 6a 10 80       	push   $0x80106a98
80102bf6:	53                   	push   %ebx
80102bf7:	e8 66 11 00 00       	call   80103d62 <memcmp>
80102bfc:	83 c4 10             	add    $0x10,%esp
80102bff:	85 c0                	test   %eax,%eax
80102c01:	75 e2                	jne    80102be5 <mpsearch1+0x11>
80102c03:	ba 10 00 00 00       	mov    $0x10,%edx
80102c08:	89 d8                	mov    %ebx,%eax
80102c0a:	e8 a1 ff ff ff       	call   80102bb0 <sum>
80102c0f:	84 c0                	test   %al,%al
80102c11:	75 d2                	jne    80102be5 <mpsearch1+0x11>
80102c13:	eb 05                	jmp    80102c1a <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102c15:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102c1a:	89 d8                	mov    %ebx,%eax
80102c1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102c1f:	5b                   	pop    %ebx
80102c20:	5e                   	pop    %esi
80102c21:	5d                   	pop    %ebp
80102c22:	c3                   	ret    

80102c23 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
80102c26:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c29:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c30:	c1 e0 08             	shl    $0x8,%eax
80102c33:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c3a:	09 d0                	or     %edx,%eax
80102c3c:	c1 e0 04             	shl    $0x4,%eax
80102c3f:	85 c0                	test   %eax,%eax
80102c41:	74 1f                	je     80102c62 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102c43:	ba 00 04 00 00       	mov    $0x400,%edx
80102c48:	e8 87 ff ff ff       	call   80102bd4 <mpsearch1>
80102c4d:	85 c0                	test   %eax,%eax
80102c4f:	75 0f                	jne    80102c60 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102c51:	ba 00 00 01 00       	mov    $0x10000,%edx
80102c56:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102c5b:	e8 74 ff ff ff       	call   80102bd4 <mpsearch1>
}
80102c60:	c9                   	leave  
80102c61:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102c62:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102c69:	c1 e0 08             	shl    $0x8,%eax
80102c6c:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102c73:	09 d0                	or     %edx,%eax
80102c75:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102c78:	2d 00 04 00 00       	sub    $0x400,%eax
80102c7d:	ba 00 04 00 00       	mov    $0x400,%edx
80102c82:	e8 4d ff ff ff       	call   80102bd4 <mpsearch1>
80102c87:	85 c0                	test   %eax,%eax
80102c89:	75 d5                	jne    80102c60 <mpsearch+0x3d>
80102c8b:	eb c4                	jmp    80102c51 <mpsearch+0x2e>

80102c8d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102c8d:	55                   	push   %ebp
80102c8e:	89 e5                	mov    %esp,%ebp
80102c90:	57                   	push   %edi
80102c91:	56                   	push   %esi
80102c92:	53                   	push   %ebx
80102c93:	83 ec 1c             	sub    $0x1c,%esp
80102c96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c99:	e8 85 ff ff ff       	call   80102c23 <mpsearch>
80102c9e:	85 c0                	test   %eax,%eax
80102ca0:	74 5c                	je     80102cfe <mpconfig+0x71>
80102ca2:	89 c7                	mov    %eax,%edi
80102ca4:	8b 58 04             	mov    0x4(%eax),%ebx
80102ca7:	85 db                	test   %ebx,%ebx
80102ca9:	74 5a                	je     80102d05 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102cab:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102cb1:	83 ec 04             	sub    $0x4,%esp
80102cb4:	6a 04                	push   $0x4
80102cb6:	68 9d 6a 10 80       	push   $0x80106a9d
80102cbb:	56                   	push   %esi
80102cbc:	e8 a1 10 00 00       	call   80103d62 <memcmp>
80102cc1:	83 c4 10             	add    $0x10,%esp
80102cc4:	85 c0                	test   %eax,%eax
80102cc6:	75 44                	jne    80102d0c <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102cc8:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102ccf:	3c 01                	cmp    $0x1,%al
80102cd1:	0f 95 c2             	setne  %dl
80102cd4:	3c 04                	cmp    $0x4,%al
80102cd6:	0f 95 c0             	setne  %al
80102cd9:	84 c2                	test   %al,%dl
80102cdb:	75 36                	jne    80102d13 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102cdd:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102ce4:	89 f0                	mov    %esi,%eax
80102ce6:	e8 c5 fe ff ff       	call   80102bb0 <sum>
80102ceb:	84 c0                	test   %al,%al
80102ced:	75 2b                	jne    80102d1a <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102cef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102cf2:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102cf4:	89 f0                	mov    %esi,%eax
80102cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cf9:	5b                   	pop    %ebx
80102cfa:	5e                   	pop    %esi
80102cfb:	5f                   	pop    %edi
80102cfc:	5d                   	pop    %ebp
80102cfd:	c3                   	ret    
    return 0;
80102cfe:	be 00 00 00 00       	mov    $0x0,%esi
80102d03:	eb ef                	jmp    80102cf4 <mpconfig+0x67>
80102d05:	be 00 00 00 00       	mov    $0x0,%esi
80102d0a:	eb e8                	jmp    80102cf4 <mpconfig+0x67>
    return 0;
80102d0c:	be 00 00 00 00       	mov    $0x0,%esi
80102d11:	eb e1                	jmp    80102cf4 <mpconfig+0x67>
    return 0;
80102d13:	be 00 00 00 00       	mov    $0x0,%esi
80102d18:	eb da                	jmp    80102cf4 <mpconfig+0x67>
    return 0;
80102d1a:	be 00 00 00 00       	mov    $0x0,%esi
80102d1f:	eb d3                	jmp    80102cf4 <mpconfig+0x67>

80102d21 <mpinit>:

void
mpinit(void)
{
80102d21:	55                   	push   %ebp
80102d22:	89 e5                	mov    %esp,%ebp
80102d24:	57                   	push   %edi
80102d25:	56                   	push   %esi
80102d26:	53                   	push   %ebx
80102d27:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102d2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102d2d:	e8 5b ff ff ff       	call   80102c8d <mpconfig>
80102d32:	85 c0                	test   %eax,%eax
80102d34:	74 19                	je     80102d4f <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d36:	8b 50 24             	mov    0x24(%eax),%edx
80102d39:	89 15 9c 16 13 80    	mov    %edx,0x8013169c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d3f:	8d 50 2c             	lea    0x2c(%eax),%edx
80102d42:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102d46:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d4d:	eb 34                	jmp    80102d83 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102d4f:	83 ec 0c             	sub    $0xc,%esp
80102d52:	68 a2 6a 10 80       	push   $0x80106aa2
80102d57:	e8 ec d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102d5c:	8b 35 20 1d 13 80    	mov    0x80131d20,%esi
80102d62:	83 fe 07             	cmp    $0x7,%esi
80102d65:	7f 19                	jg     80102d80 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102d67:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d6b:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102d71:	88 87 a0 17 13 80    	mov    %al,-0x7fece860(%edi)
        ncpu++;
80102d77:	83 c6 01             	add    $0x1,%esi
80102d7a:	89 35 20 1d 13 80    	mov    %esi,0x80131d20
      }
      p += sizeof(struct mpproc);
80102d80:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d83:	39 ca                	cmp    %ecx,%edx
80102d85:	73 2b                	jae    80102db2 <mpinit+0x91>
    switch(*p){
80102d87:	0f b6 02             	movzbl (%edx),%eax
80102d8a:	3c 04                	cmp    $0x4,%al
80102d8c:	77 1d                	ja     80102dab <mpinit+0x8a>
80102d8e:	0f b6 c0             	movzbl %al,%eax
80102d91:	ff 24 85 dc 6a 10 80 	jmp    *-0x7fef9524(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102d98:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d9c:	a2 80 17 13 80       	mov    %al,0x80131780
      p += sizeof(struct mpioapic);
80102da1:	83 c2 08             	add    $0x8,%edx
      continue;
80102da4:	eb dd                	jmp    80102d83 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102da6:	83 c2 08             	add    $0x8,%edx
      continue;
80102da9:	eb d8                	jmp    80102d83 <mpinit+0x62>
    default:
      ismp = 0;
80102dab:	bb 00 00 00 00       	mov    $0x0,%ebx
80102db0:	eb d1                	jmp    80102d83 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102db2:	85 db                	test   %ebx,%ebx
80102db4:	74 26                	je     80102ddc <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102db9:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102dbd:	74 15                	je     80102dd4 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dbf:	b8 70 00 00 00       	mov    $0x70,%eax
80102dc4:	ba 22 00 00 00       	mov    $0x22,%edx
80102dc9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dca:	ba 23 00 00 00       	mov    $0x23,%edx
80102dcf:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102dd0:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dd3:	ee                   	out    %al,(%dx)
  }
}
80102dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dd7:	5b                   	pop    %ebx
80102dd8:	5e                   	pop    %esi
80102dd9:	5f                   	pop    %edi
80102dda:	5d                   	pop    %ebp
80102ddb:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102ddc:	83 ec 0c             	sub    $0xc,%esp
80102ddf:	68 bc 6a 10 80       	push   $0x80106abc
80102de4:	e8 5f d5 ff ff       	call   80100348 <panic>

80102de9 <picinit>:
80102de9:	55                   	push   %ebp
80102dea:	89 e5                	mov    %esp,%ebp
80102dec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102df1:	ba 21 00 00 00       	mov    $0x21,%edx
80102df6:	ee                   	out    %al,(%dx)
80102df7:	ba a1 00 00 00       	mov    $0xa1,%edx
80102dfc:	ee                   	out    %al,(%dx)
80102dfd:	5d                   	pop    %ebp
80102dfe:	c3                   	ret    

80102dff <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102dff:	55                   	push   %ebp
80102e00:	89 e5                	mov    %esp,%ebp
80102e02:	57                   	push   %edi
80102e03:	56                   	push   %esi
80102e04:	53                   	push   %ebx
80102e05:	83 ec 0c             	sub    $0xc,%esp
80102e08:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e0e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e14:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102e1a:	e8 1a de ff ff       	call   80100c39 <filealloc>
80102e1f:	89 03                	mov    %eax,(%ebx)
80102e21:	85 c0                	test   %eax,%eax
80102e23:	74 1e                	je     80102e43 <pipealloc+0x44>
80102e25:	e8 0f de ff ff       	call   80100c39 <filealloc>
80102e2a:	89 06                	mov    %eax,(%esi)
80102e2c:	85 c0                	test   %eax,%eax
80102e2e:	74 13                	je     80102e43 <pipealloc+0x44>
    goto bad;
  if((p = (struct pipe*)kalloc(-2)) == 0)
80102e30:	83 ec 0c             	sub    $0xc,%esp
80102e33:	6a fe                	push   $0xfffffffe
80102e35:	e8 8d f2 ff ff       	call   801020c7 <kalloc>
80102e3a:	89 c7                	mov    %eax,%edi
80102e3c:	83 c4 10             	add    $0x10,%esp
80102e3f:	85 c0                	test   %eax,%eax
80102e41:	75 35                	jne    80102e78 <pipealloc+0x79>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102e43:	8b 03                	mov    (%ebx),%eax
80102e45:	85 c0                	test   %eax,%eax
80102e47:	74 0c                	je     80102e55 <pipealloc+0x56>
    fileclose(*f0);
80102e49:	83 ec 0c             	sub    $0xc,%esp
80102e4c:	50                   	push   %eax
80102e4d:	e8 8d de ff ff       	call   80100cdf <fileclose>
80102e52:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102e55:	8b 06                	mov    (%esi),%eax
80102e57:	85 c0                	test   %eax,%eax
80102e59:	0f 84 8b 00 00 00    	je     80102eea <pipealloc+0xeb>
    fileclose(*f1);
80102e5f:	83 ec 0c             	sub    $0xc,%esp
80102e62:	50                   	push   %eax
80102e63:	e8 77 de ff ff       	call   80100cdf <fileclose>
80102e68:	83 c4 10             	add    $0x10,%esp
  return -1;
80102e6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e73:	5b                   	pop    %ebx
80102e74:	5e                   	pop    %esi
80102e75:	5f                   	pop    %edi
80102e76:	5d                   	pop    %ebp
80102e77:	c3                   	ret    
  p->readopen = 1;
80102e78:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102e7f:	00 00 00 
  p->writeopen = 1;
80102e82:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102e89:	00 00 00 
  p->nwrite = 0;
80102e8c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e93:	00 00 00 
  p->nread = 0;
80102e96:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e9d:	00 00 00 
  initlock(&p->lock, "pipe");
80102ea0:	83 ec 08             	sub    $0x8,%esp
80102ea3:	68 f0 6a 10 80       	push   $0x80106af0
80102ea8:	50                   	push   %eax
80102ea9:	e8 86 0c 00 00       	call   80103b34 <initlock>
  (*f0)->type = FD_PIPE;
80102eae:	8b 03                	mov    (%ebx),%eax
80102eb0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102eb6:	8b 03                	mov    (%ebx),%eax
80102eb8:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102ebc:	8b 03                	mov    (%ebx),%eax
80102ebe:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102ec2:	8b 03                	mov    (%ebx),%eax
80102ec4:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102ec7:	8b 06                	mov    (%esi),%eax
80102ec9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102ecf:	8b 06                	mov    (%esi),%eax
80102ed1:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102ed5:	8b 06                	mov    (%esi),%eax
80102ed7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102edb:	8b 06                	mov    (%esi),%eax
80102edd:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102ee0:	83 c4 10             	add    $0x10,%esp
80102ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ee8:	eb 86                	jmp    80102e70 <pipealloc+0x71>
  return -1;
80102eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eef:	e9 7c ff ff ff       	jmp    80102e70 <pipealloc+0x71>

80102ef4 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102ef4:	55                   	push   %ebp
80102ef5:	89 e5                	mov    %esp,%ebp
80102ef7:	53                   	push   %ebx
80102ef8:	83 ec 10             	sub    $0x10,%esp
80102efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102efe:	53                   	push   %ebx
80102eff:	e8 6c 0d 00 00       	call   80103c70 <acquire>
  if(writable){
80102f04:	83 c4 10             	add    $0x10,%esp
80102f07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f0b:	74 3f                	je     80102f4c <pipeclose+0x58>
    p->writeopen = 0;
80102f0d:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f14:	00 00 00 
    wakeup(&p->nread);
80102f17:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f1d:	83 ec 0c             	sub    $0xc,%esp
80102f20:	50                   	push   %eax
80102f21:	e8 b4 09 00 00       	call   801038da <wakeup>
80102f26:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f29:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f30:	75 09                	jne    80102f3b <pipeclose+0x47>
80102f32:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f39:	74 2f                	je     80102f6a <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102f3b:	83 ec 0c             	sub    $0xc,%esp
80102f3e:	53                   	push   %ebx
80102f3f:	e8 91 0d 00 00       	call   80103cd5 <release>
80102f44:	83 c4 10             	add    $0x10,%esp
}
80102f47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f4a:	c9                   	leave  
80102f4b:	c3                   	ret    
    p->readopen = 0;
80102f4c:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f53:	00 00 00 
    wakeup(&p->nwrite);
80102f56:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f5c:	83 ec 0c             	sub    $0xc,%esp
80102f5f:	50                   	push   %eax
80102f60:	e8 75 09 00 00       	call   801038da <wakeup>
80102f65:	83 c4 10             	add    $0x10,%esp
80102f68:	eb bf                	jmp    80102f29 <pipeclose+0x35>
    release(&p->lock);
80102f6a:	83 ec 0c             	sub    $0xc,%esp
80102f6d:	53                   	push   %ebx
80102f6e:	e8 62 0d 00 00       	call   80103cd5 <release>
    kfree((char*)p);
80102f73:	89 1c 24             	mov    %ebx,(%esp)
80102f76:	e8 35 f0 ff ff       	call   80101fb0 <kfree>
80102f7b:	83 c4 10             	add    $0x10,%esp
80102f7e:	eb c7                	jmp    80102f47 <pipeclose+0x53>

80102f80 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102f80:	55                   	push   %ebp
80102f81:	89 e5                	mov    %esp,%ebp
80102f83:	57                   	push   %edi
80102f84:	56                   	push   %esi
80102f85:	53                   	push   %ebx
80102f86:	83 ec 18             	sub    $0x18,%esp
80102f89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f8c:	89 de                	mov    %ebx,%esi
80102f8e:	53                   	push   %ebx
80102f8f:	e8 dc 0c 00 00       	call   80103c70 <acquire>
  for(i = 0; i < n; i++){
80102f94:	83 c4 10             	add    $0x10,%esp
80102f97:	bf 00 00 00 00       	mov    $0x0,%edi
80102f9c:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102f9f:	0f 8d 88 00 00 00    	jge    8010302d <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102fa5:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102fab:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102fb1:	05 00 02 00 00       	add    $0x200,%eax
80102fb6:	39 c2                	cmp    %eax,%edx
80102fb8:	75 51                	jne    8010300b <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102fba:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102fc1:	74 2f                	je     80102ff2 <pipewrite+0x72>
80102fc3:	e8 06 03 00 00       	call   801032ce <myproc>
80102fc8:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fcc:	75 24                	jne    80102ff2 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102fce:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fd4:	83 ec 0c             	sub    $0xc,%esp
80102fd7:	50                   	push   %eax
80102fd8:	e8 fd 08 00 00       	call   801038da <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102fdd:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fe3:	83 c4 08             	add    $0x8,%esp
80102fe6:	56                   	push   %esi
80102fe7:	50                   	push   %eax
80102fe8:	e8 88 07 00 00       	call   80103775 <sleep>
80102fed:	83 c4 10             	add    $0x10,%esp
80102ff0:	eb b3                	jmp    80102fa5 <pipewrite+0x25>
        release(&p->lock);
80102ff2:	83 ec 0c             	sub    $0xc,%esp
80102ff5:	53                   	push   %ebx
80102ff6:	e8 da 0c 00 00       	call   80103cd5 <release>
        return -1;
80102ffb:	83 c4 10             	add    $0x10,%esp
80102ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103003:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103006:	5b                   	pop    %ebx
80103007:	5e                   	pop    %esi
80103008:	5f                   	pop    %edi
80103009:	5d                   	pop    %ebp
8010300a:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010300b:	8d 42 01             	lea    0x1(%edx),%eax
8010300e:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103014:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010301a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010301d:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80103021:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103025:	83 c7 01             	add    $0x1,%edi
80103028:	e9 6f ff ff ff       	jmp    80102f9c <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010302d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103033:	83 ec 0c             	sub    $0xc,%esp
80103036:	50                   	push   %eax
80103037:	e8 9e 08 00 00       	call   801038da <wakeup>
  release(&p->lock);
8010303c:	89 1c 24             	mov    %ebx,(%esp)
8010303f:	e8 91 0c 00 00       	call   80103cd5 <release>
  return n;
80103044:	83 c4 10             	add    $0x10,%esp
80103047:	8b 45 10             	mov    0x10(%ebp),%eax
8010304a:	eb b7                	jmp    80103003 <pipewrite+0x83>

8010304c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010304c:	55                   	push   %ebp
8010304d:	89 e5                	mov    %esp,%ebp
8010304f:	57                   	push   %edi
80103050:	56                   	push   %esi
80103051:	53                   	push   %ebx
80103052:	83 ec 18             	sub    $0x18,%esp
80103055:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103058:	89 df                	mov    %ebx,%edi
8010305a:	53                   	push   %ebx
8010305b:	e8 10 0c 00 00       	call   80103c70 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103060:	83 c4 10             	add    $0x10,%esp
80103063:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103069:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
8010306f:	75 3d                	jne    801030ae <piperead+0x62>
80103071:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103077:	85 f6                	test   %esi,%esi
80103079:	74 38                	je     801030b3 <piperead+0x67>
    if(myproc()->killed){
8010307b:	e8 4e 02 00 00       	call   801032ce <myproc>
80103080:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103084:	75 15                	jne    8010309b <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103086:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010308c:	83 ec 08             	sub    $0x8,%esp
8010308f:	57                   	push   %edi
80103090:	50                   	push   %eax
80103091:	e8 df 06 00 00       	call   80103775 <sleep>
80103096:	83 c4 10             	add    $0x10,%esp
80103099:	eb c8                	jmp    80103063 <piperead+0x17>
      release(&p->lock);
8010309b:	83 ec 0c             	sub    $0xc,%esp
8010309e:	53                   	push   %ebx
8010309f:	e8 31 0c 00 00       	call   80103cd5 <release>
      return -1;
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	be ff ff ff ff       	mov    $0xffffffff,%esi
801030ac:	eb 50                	jmp    801030fe <piperead+0xb2>
801030ae:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801030b3:	3b 75 10             	cmp    0x10(%ebp),%esi
801030b6:	7d 2c                	jge    801030e4 <piperead+0x98>
    if(p->nread == p->nwrite)
801030b8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030be:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801030c4:	74 1e                	je     801030e4 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801030c6:	8d 50 01             	lea    0x1(%eax),%edx
801030c9:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801030cf:	25 ff 01 00 00       	and    $0x1ff,%eax
801030d4:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801030d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801030dc:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801030df:	83 c6 01             	add    $0x1,%esi
801030e2:	eb cf                	jmp    801030b3 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801030e4:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030ea:	83 ec 0c             	sub    $0xc,%esp
801030ed:	50                   	push   %eax
801030ee:	e8 e7 07 00 00       	call   801038da <wakeup>
  release(&p->lock);
801030f3:	89 1c 24             	mov    %ebx,(%esp)
801030f6:	e8 da 0b 00 00       	call   80103cd5 <release>
  return i;
801030fb:	83 c4 10             	add    $0x10,%esp
}
801030fe:	89 f0                	mov    %esi,%eax
80103100:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103103:	5b                   	pop    %ebx
80103104:	5e                   	pop    %esi
80103105:	5f                   	pop    %edi
80103106:	5d                   	pop    %ebp
80103107:	c3                   	ret    

80103108 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103108:	55                   	push   %ebp
80103109:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010310b:	ba 74 1d 13 80       	mov    $0x80131d74,%edx
80103110:	eb 03                	jmp    80103115 <wakeup1+0xd>
80103112:	83 c2 7c             	add    $0x7c,%edx
80103115:	81 fa 74 3c 13 80    	cmp    $0x80133c74,%edx
8010311b:	73 14                	jae    80103131 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010311d:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103121:	75 ef                	jne    80103112 <wakeup1+0xa>
80103123:	39 42 20             	cmp    %eax,0x20(%edx)
80103126:	75 ea                	jne    80103112 <wakeup1+0xa>
      p->state = RUNNABLE;
80103128:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010312f:	eb e1                	jmp    80103112 <wakeup1+0xa>
}
80103131:	5d                   	pop    %ebp
80103132:	c3                   	ret    

80103133 <allocproc>:
{
80103133:	55                   	push   %ebp
80103134:	89 e5                	mov    %esp,%ebp
80103136:	53                   	push   %ebx
80103137:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010313a:	68 40 1d 13 80       	push   $0x80131d40
8010313f:	e8 2c 0b 00 00       	call   80103c70 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103144:	83 c4 10             	add    $0x10,%esp
80103147:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
8010314c:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103152:	73 0b                	jae    8010315f <allocproc+0x2c>
    if(p->state == UNUSED)
80103154:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103158:	74 1c                	je     80103176 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010315a:	83 c3 7c             	add    $0x7c,%ebx
8010315d:	eb ed                	jmp    8010314c <allocproc+0x19>
  release(&ptable.lock);
8010315f:	83 ec 0c             	sub    $0xc,%esp
80103162:	68 40 1d 13 80       	push   $0x80131d40
80103167:	e8 69 0b 00 00       	call   80103cd5 <release>
  return 0;
8010316c:	83 c4 10             	add    $0x10,%esp
8010316f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103174:	eb 6f                	jmp    801031e5 <allocproc+0xb2>
  p->state = EMBRYO;
80103176:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
8010317d:	a1 04 90 12 80       	mov    0x80129004,%eax
80103182:	8d 50 01             	lea    0x1(%eax),%edx
80103185:	89 15 04 90 12 80    	mov    %edx,0x80129004
8010318b:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010318e:	83 ec 0c             	sub    $0xc,%esp
80103191:	68 40 1d 13 80       	push   $0x80131d40
80103196:	e8 3a 0b 00 00       	call   80103cd5 <release>
  if((p->kstack = kalloc(p->pid)) == 0){
8010319b:	83 c4 04             	add    $0x4,%esp
8010319e:	ff 73 10             	pushl  0x10(%ebx)
801031a1:	e8 21 ef ff ff       	call   801020c7 <kalloc>
801031a6:	89 43 08             	mov    %eax,0x8(%ebx)
801031a9:	83 c4 10             	add    $0x10,%esp
801031ac:	85 c0                	test   %eax,%eax
801031ae:	74 3c                	je     801031ec <allocproc+0xb9>
  sp -= sizeof *p->tf;
801031b0:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801031b6:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801031b9:	c7 80 b0 0f 00 00 32 	movl   $0x80104e32,0xfb0(%eax)
801031c0:	4e 10 80 
  sp -= sizeof *p->context;
801031c3:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801031c8:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801031cb:	83 ec 04             	sub    $0x4,%esp
801031ce:	6a 14                	push   $0x14
801031d0:	6a 00                	push   $0x0
801031d2:	50                   	push   %eax
801031d3:	e8 44 0b 00 00       	call   80103d1c <memset>
  p->context->eip = (uint)forkret;
801031d8:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031db:	c7 40 10 fa 31 10 80 	movl   $0x801031fa,0x10(%eax)
  return p;
801031e2:	83 c4 10             	add    $0x10,%esp
}
801031e5:	89 d8                	mov    %ebx,%eax
801031e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801031ea:	c9                   	leave  
801031eb:	c3                   	ret    
    p->state = UNUSED;
801031ec:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801031f8:	eb eb                	jmp    801031e5 <allocproc+0xb2>

801031fa <forkret>:
{
801031fa:	55                   	push   %ebp
801031fb:	89 e5                	mov    %esp,%ebp
801031fd:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103200:	68 40 1d 13 80       	push   $0x80131d40
80103205:	e8 cb 0a 00 00       	call   80103cd5 <release>
  if (first) {
8010320a:	83 c4 10             	add    $0x10,%esp
8010320d:	83 3d 00 90 12 80 00 	cmpl   $0x0,0x80129000
80103214:	75 02                	jne    80103218 <forkret+0x1e>
}
80103216:	c9                   	leave  
80103217:	c3                   	ret    
    first = 0;
80103218:	c7 05 00 90 12 80 00 	movl   $0x0,0x80129000
8010321f:	00 00 00 
    iinit(ROOTDEV);
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	6a 01                	push   $0x1
80103227:	e8 cc e0 ff ff       	call   801012f8 <iinit>
    initlog(ROOTDEV);
8010322c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103233:	e8 f2 f5 ff ff       	call   8010282a <initlog>
80103238:	83 c4 10             	add    $0x10,%esp
}
8010323b:	eb d9                	jmp    80103216 <forkret+0x1c>

8010323d <pinit>:
{
8010323d:	55                   	push   %ebp
8010323e:	89 e5                	mov    %esp,%ebp
80103240:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103243:	68 f5 6a 10 80       	push   $0x80106af5
80103248:	68 40 1d 13 80       	push   $0x80131d40
8010324d:	e8 e2 08 00 00       	call   80103b34 <initlock>
}
80103252:	83 c4 10             	add    $0x10,%esp
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <mycpu>:
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010325d:	9c                   	pushf  
8010325e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010325f:	f6 c4 02             	test   $0x2,%ah
80103262:	75 28                	jne    8010328c <mycpu+0x35>
  apicid = lapicid();
80103264:	e8 da f1 ff ff       	call   80102443 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103269:	ba 00 00 00 00       	mov    $0x0,%edx
8010326e:	39 15 20 1d 13 80    	cmp    %edx,0x80131d20
80103274:	7e 23                	jle    80103299 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103276:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010327c:	0f b6 89 a0 17 13 80 	movzbl -0x7fece860(%ecx),%ecx
80103283:	39 c1                	cmp    %eax,%ecx
80103285:	74 1f                	je     801032a6 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103287:	83 c2 01             	add    $0x1,%edx
8010328a:	eb e2                	jmp    8010326e <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010328c:	83 ec 0c             	sub    $0xc,%esp
8010328f:	68 d8 6b 10 80       	push   $0x80106bd8
80103294:	e8 af d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 fc 6a 10 80       	push   $0x80106afc
801032a1:	e8 a2 d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
801032a6:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801032ac:	05 a0 17 13 80       	add    $0x801317a0,%eax
}
801032b1:	c9                   	leave  
801032b2:	c3                   	ret    

801032b3 <cpuid>:
cpuid() {
801032b3:	55                   	push   %ebp
801032b4:	89 e5                	mov    %esp,%ebp
801032b6:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801032b9:	e8 99 ff ff ff       	call   80103257 <mycpu>
801032be:	2d a0 17 13 80       	sub    $0x801317a0,%eax
801032c3:	c1 f8 04             	sar    $0x4,%eax
801032c6:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032cc:	c9                   	leave  
801032cd:	c3                   	ret    

801032ce <myproc>:
myproc(void) {
801032ce:	55                   	push   %ebp
801032cf:	89 e5                	mov    %esp,%ebp
801032d1:	53                   	push   %ebx
801032d2:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032d5:	e8 b9 08 00 00       	call   80103b93 <pushcli>
  c = mycpu();
801032da:	e8 78 ff ff ff       	call   80103257 <mycpu>
  p = c->proc;
801032df:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032e5:	e8 e6 08 00 00       	call   80103bd0 <popcli>
}
801032ea:	89 d8                	mov    %ebx,%eax
801032ec:	83 c4 04             	add    $0x4,%esp
801032ef:	5b                   	pop    %ebx
801032f0:	5d                   	pop    %ebp
801032f1:	c3                   	ret    

801032f2 <userinit>:
{
801032f2:	55                   	push   %ebp
801032f3:	89 e5                	mov    %esp,%ebp
801032f5:	53                   	push   %ebx
801032f6:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801032f9:	e8 35 fe ff ff       	call   80103133 <allocproc>
801032fe:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103300:	a3 bc 95 12 80       	mov    %eax,0x801295bc
  if((p->pgdir = setupkvm()) == 0)
80103305:	e8 22 30 00 00       	call   8010632c <setupkvm>
8010330a:	89 43 04             	mov    %eax,0x4(%ebx)
8010330d:	85 c0                	test   %eax,%eax
8010330f:	0f 84 b7 00 00 00    	je     801033cc <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103315:	83 ec 04             	sub    $0x4,%esp
80103318:	68 2c 00 00 00       	push   $0x2c
8010331d:	68 60 94 12 80       	push   $0x80129460
80103322:	50                   	push   %eax
80103323:	e8 01 2d 00 00       	call   80106029 <inituvm>
  p->sz = PGSIZE;
80103328:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010332e:	83 c4 0c             	add    $0xc,%esp
80103331:	6a 4c                	push   $0x4c
80103333:	6a 00                	push   $0x0
80103335:	ff 73 18             	pushl  0x18(%ebx)
80103338:	e8 df 09 00 00       	call   80103d1c <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010333d:	8b 43 18             	mov    0x18(%ebx),%eax
80103340:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103346:	8b 43 18             	mov    0x18(%ebx),%eax
80103349:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010334f:	8b 43 18             	mov    0x18(%ebx),%eax
80103352:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103356:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010335a:	8b 43 18             	mov    0x18(%ebx),%eax
8010335d:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103361:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103365:	8b 43 18             	mov    0x18(%ebx),%eax
80103368:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010336f:	8b 43 18             	mov    0x18(%ebx),%eax
80103372:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103379:	8b 43 18             	mov    0x18(%ebx),%eax
8010337c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103383:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103386:	83 c4 0c             	add    $0xc,%esp
80103389:	6a 10                	push   $0x10
8010338b:	68 25 6b 10 80       	push   $0x80106b25
80103390:	50                   	push   %eax
80103391:	e8 ed 0a 00 00       	call   80103e83 <safestrcpy>
  p->cwd = namei("/");
80103396:	c7 04 24 2e 6b 10 80 	movl   $0x80106b2e,(%esp)
8010339d:	e8 4b e8 ff ff       	call   80101bed <namei>
801033a2:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801033a5:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801033ac:	e8 bf 08 00 00       	call   80103c70 <acquire>
  p->state = RUNNABLE;
801033b1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801033b8:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801033bf:	e8 11 09 00 00       	call   80103cd5 <release>
}
801033c4:	83 c4 10             	add    $0x10,%esp
801033c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033ca:	c9                   	leave  
801033cb:	c3                   	ret    
    panic("userinit: out of memory?");
801033cc:	83 ec 0c             	sub    $0xc,%esp
801033cf:	68 0c 6b 10 80       	push   $0x80106b0c
801033d4:	e8 6f cf ff ff       	call   80100348 <panic>

801033d9 <growproc>:
{
801033d9:	55                   	push   %ebp
801033da:	89 e5                	mov    %esp,%ebp
801033dc:	56                   	push   %esi
801033dd:	53                   	push   %ebx
801033de:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033e1:	e8 e8 fe ff ff       	call   801032ce <myproc>
801033e6:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033e8:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033ea:	85 f6                	test   %esi,%esi
801033ec:	7f 21                	jg     8010340f <growproc+0x36>
  } else if(n < 0){
801033ee:	85 f6                	test   %esi,%esi
801033f0:	79 33                	jns    80103425 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033f2:	83 ec 04             	sub    $0x4,%esp
801033f5:	01 c6                	add    %eax,%esi
801033f7:	56                   	push   %esi
801033f8:	50                   	push   %eax
801033f9:	ff 73 04             	pushl  0x4(%ebx)
801033fc:	e8 36 2d 00 00       	call   80106137 <deallocuvm>
80103401:	83 c4 10             	add    $0x10,%esp
80103404:	85 c0                	test   %eax,%eax
80103406:	75 1d                	jne    80103425 <growproc+0x4c>
      return -1;
80103408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010340d:	eb 29                	jmp    80103438 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n, curproc->pid)) == 0)
8010340f:	ff 73 10             	pushl  0x10(%ebx)
80103412:	01 c6                	add    %eax,%esi
80103414:	56                   	push   %esi
80103415:	50                   	push   %eax
80103416:	ff 73 04             	pushl  0x4(%ebx)
80103419:	e8 ab 2d 00 00       	call   801061c9 <allocuvm>
8010341e:	83 c4 10             	add    $0x10,%esp
80103421:	85 c0                	test   %eax,%eax
80103423:	74 1a                	je     8010343f <growproc+0x66>
  curproc->sz = sz;
80103425:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103427:	83 ec 0c             	sub    $0xc,%esp
8010342a:	53                   	push   %ebx
8010342b:	e8 e1 2a 00 00       	call   80105f11 <switchuvm>
  return 0;
80103430:	83 c4 10             	add    $0x10,%esp
80103433:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103438:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010343b:	5b                   	pop    %ebx
8010343c:	5e                   	pop    %esi
8010343d:	5d                   	pop    %ebp
8010343e:	c3                   	ret    
      return -1;
8010343f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103444:	eb f2                	jmp    80103438 <growproc+0x5f>

80103446 <fork>:
{
80103446:	55                   	push   %ebp
80103447:	89 e5                	mov    %esp,%ebp
80103449:	57                   	push   %edi
8010344a:	56                   	push   %esi
8010344b:	53                   	push   %ebx
8010344c:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010344f:	e8 7a fe ff ff       	call   801032ce <myproc>
80103454:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103456:	e8 d8 fc ff ff       	call   80103133 <allocproc>
8010345b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010345e:	85 c0                	test   %eax,%eax
80103460:	0f 84 e3 00 00 00    	je     80103549 <fork+0x103>
80103466:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->pid)) == 0){
80103468:	83 ec 04             	sub    $0x4,%esp
8010346b:	ff 73 10             	pushl  0x10(%ebx)
8010346e:	ff 33                	pushl  (%ebx)
80103470:	ff 73 04             	pushl  0x4(%ebx)
80103473:	e8 6d 2f 00 00       	call   801063e5 <copyuvm>
80103478:	89 47 04             	mov    %eax,0x4(%edi)
8010347b:	83 c4 10             	add    $0x10,%esp
8010347e:	85 c0                	test   %eax,%eax
80103480:	74 2a                	je     801034ac <fork+0x66>
  np->sz = curproc->sz;
80103482:	8b 03                	mov    (%ebx),%eax
80103484:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103487:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103489:	89 c8                	mov    %ecx,%eax
8010348b:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010348e:	8b 73 18             	mov    0x18(%ebx),%esi
80103491:	8b 79 18             	mov    0x18(%ecx),%edi
80103494:	b9 13 00 00 00       	mov    $0x13,%ecx
80103499:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010349b:	8b 40 18             	mov    0x18(%eax),%eax
8010349e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801034a5:	be 00 00 00 00       	mov    $0x0,%esi
801034aa:	eb 29                	jmp    801034d5 <fork+0x8f>
    kfree(np->kstack);
801034ac:	83 ec 0c             	sub    $0xc,%esp
801034af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801034b2:	ff 73 08             	pushl  0x8(%ebx)
801034b5:	e8 f6 ea ff ff       	call   80101fb0 <kfree>
    np->kstack = 0;
801034ba:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801034c1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801034c8:	83 c4 10             	add    $0x10,%esp
801034cb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034d0:	eb 6d                	jmp    8010353f <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
801034d2:	83 c6 01             	add    $0x1,%esi
801034d5:	83 fe 0f             	cmp    $0xf,%esi
801034d8:	7f 1d                	jg     801034f7 <fork+0xb1>
    if(curproc->ofile[i])
801034da:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034de:	85 c0                	test   %eax,%eax
801034e0:	74 f0                	je     801034d2 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034e2:	83 ec 0c             	sub    $0xc,%esp
801034e5:	50                   	push   %eax
801034e6:	e8 af d7 ff ff       	call   80100c9a <filedup>
801034eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034ee:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801034f2:	83 c4 10             	add    $0x10,%esp
801034f5:	eb db                	jmp    801034d2 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
801034f7:	83 ec 0c             	sub    $0xc,%esp
801034fa:	ff 73 68             	pushl  0x68(%ebx)
801034fd:	e8 5b e0 ff ff       	call   8010155d <idup>
80103502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103505:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103508:	83 c3 6c             	add    $0x6c,%ebx
8010350b:	8d 47 6c             	lea    0x6c(%edi),%eax
8010350e:	83 c4 0c             	add    $0xc,%esp
80103511:	6a 10                	push   $0x10
80103513:	53                   	push   %ebx
80103514:	50                   	push   %eax
80103515:	e8 69 09 00 00       	call   80103e83 <safestrcpy>
  pid = np->pid;
8010351a:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010351d:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103524:	e8 47 07 00 00       	call   80103c70 <acquire>
  np->state = RUNNABLE;
80103529:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103530:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103537:	e8 99 07 00 00       	call   80103cd5 <release>
  return pid;
8010353c:	83 c4 10             	add    $0x10,%esp
}
8010353f:	89 d8                	mov    %ebx,%eax
80103541:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103544:	5b                   	pop    %ebx
80103545:	5e                   	pop    %esi
80103546:	5f                   	pop    %edi
80103547:	5d                   	pop    %ebp
80103548:	c3                   	ret    
    return -1;
80103549:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010354e:	eb ef                	jmp    8010353f <fork+0xf9>

80103550 <scheduler>:
{
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	56                   	push   %esi
80103554:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103555:	e8 fd fc ff ff       	call   80103257 <mycpu>
8010355a:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010355c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103563:	00 00 00 
80103566:	eb 5a                	jmp    801035c2 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103568:	83 c3 7c             	add    $0x7c,%ebx
8010356b:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103571:	73 3f                	jae    801035b2 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103573:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103577:	75 ef                	jne    80103568 <scheduler+0x18>
      c->proc = p;
80103579:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010357f:	83 ec 0c             	sub    $0xc,%esp
80103582:	53                   	push   %ebx
80103583:	e8 89 29 00 00       	call   80105f11 <switchuvm>
      p->state = RUNNING;
80103588:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
8010358f:	83 c4 08             	add    $0x8,%esp
80103592:	ff 73 1c             	pushl  0x1c(%ebx)
80103595:	8d 46 04             	lea    0x4(%esi),%eax
80103598:	50                   	push   %eax
80103599:	e8 38 09 00 00       	call   80103ed6 <swtch>
      switchkvm();
8010359e:	e8 5c 29 00 00       	call   80105eff <switchkvm>
      c->proc = 0;
801035a3:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035aa:	00 00 00 
801035ad:	83 c4 10             	add    $0x10,%esp
801035b0:	eb b6                	jmp    80103568 <scheduler+0x18>
    release(&ptable.lock);
801035b2:	83 ec 0c             	sub    $0xc,%esp
801035b5:	68 40 1d 13 80       	push   $0x80131d40
801035ba:	e8 16 07 00 00       	call   80103cd5 <release>
    sti();
801035bf:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801035c2:	fb                   	sti    
    acquire(&ptable.lock);
801035c3:	83 ec 0c             	sub    $0xc,%esp
801035c6:	68 40 1d 13 80       	push   $0x80131d40
801035cb:	e8 a0 06 00 00       	call   80103c70 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035d0:	83 c4 10             	add    $0x10,%esp
801035d3:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
801035d8:	eb 91                	jmp    8010356b <scheduler+0x1b>

801035da <sched>:
{
801035da:	55                   	push   %ebp
801035db:	89 e5                	mov    %esp,%ebp
801035dd:	56                   	push   %esi
801035de:	53                   	push   %ebx
  struct proc *p = myproc();
801035df:	e8 ea fc ff ff       	call   801032ce <myproc>
801035e4:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	68 40 1d 13 80       	push   $0x80131d40
801035ee:	e8 3d 06 00 00       	call   80103c30 <holding>
801035f3:	83 c4 10             	add    $0x10,%esp
801035f6:	85 c0                	test   %eax,%eax
801035f8:	74 4f                	je     80103649 <sched+0x6f>
  if(mycpu()->ncli != 1)
801035fa:	e8 58 fc ff ff       	call   80103257 <mycpu>
801035ff:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103606:	75 4e                	jne    80103656 <sched+0x7c>
  if(p->state == RUNNING)
80103608:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010360c:	74 55                	je     80103663 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010360e:	9c                   	pushf  
8010360f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103610:	f6 c4 02             	test   $0x2,%ah
80103613:	75 5b                	jne    80103670 <sched+0x96>
  intena = mycpu()->intena;
80103615:	e8 3d fc ff ff       	call   80103257 <mycpu>
8010361a:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103620:	e8 32 fc ff ff       	call   80103257 <mycpu>
80103625:	83 ec 08             	sub    $0x8,%esp
80103628:	ff 70 04             	pushl  0x4(%eax)
8010362b:	83 c3 1c             	add    $0x1c,%ebx
8010362e:	53                   	push   %ebx
8010362f:	e8 a2 08 00 00       	call   80103ed6 <swtch>
  mycpu()->intena = intena;
80103634:	e8 1e fc ff ff       	call   80103257 <mycpu>
80103639:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010363f:	83 c4 10             	add    $0x10,%esp
80103642:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103645:	5b                   	pop    %ebx
80103646:	5e                   	pop    %esi
80103647:	5d                   	pop    %ebp
80103648:	c3                   	ret    
    panic("sched ptable.lock");
80103649:	83 ec 0c             	sub    $0xc,%esp
8010364c:	68 30 6b 10 80       	push   $0x80106b30
80103651:	e8 f2 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
80103656:	83 ec 0c             	sub    $0xc,%esp
80103659:	68 42 6b 10 80       	push   $0x80106b42
8010365e:	e8 e5 cc ff ff       	call   80100348 <panic>
    panic("sched running");
80103663:	83 ec 0c             	sub    $0xc,%esp
80103666:	68 4e 6b 10 80       	push   $0x80106b4e
8010366b:	e8 d8 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103670:	83 ec 0c             	sub    $0xc,%esp
80103673:	68 5c 6b 10 80       	push   $0x80106b5c
80103678:	e8 cb cc ff ff       	call   80100348 <panic>

8010367d <exit>:
{
8010367d:	55                   	push   %ebp
8010367e:	89 e5                	mov    %esp,%ebp
80103680:	56                   	push   %esi
80103681:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103682:	e8 47 fc ff ff       	call   801032ce <myproc>
  if(curproc == initproc)
80103687:	39 05 bc 95 12 80    	cmp    %eax,0x801295bc
8010368d:	74 09                	je     80103698 <exit+0x1b>
8010368f:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103691:	bb 00 00 00 00       	mov    $0x0,%ebx
80103696:	eb 10                	jmp    801036a8 <exit+0x2b>
    panic("init exiting");
80103698:	83 ec 0c             	sub    $0xc,%esp
8010369b:	68 70 6b 10 80       	push   $0x80106b70
801036a0:	e8 a3 cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801036a5:	83 c3 01             	add    $0x1,%ebx
801036a8:	83 fb 0f             	cmp    $0xf,%ebx
801036ab:	7f 1e                	jg     801036cb <exit+0x4e>
    if(curproc->ofile[fd]){
801036ad:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801036b1:	85 c0                	test   %eax,%eax
801036b3:	74 f0                	je     801036a5 <exit+0x28>
      fileclose(curproc->ofile[fd]);
801036b5:	83 ec 0c             	sub    $0xc,%esp
801036b8:	50                   	push   %eax
801036b9:	e8 21 d6 ff ff       	call   80100cdf <fileclose>
      curproc->ofile[fd] = 0;
801036be:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801036c5:	00 
801036c6:	83 c4 10             	add    $0x10,%esp
801036c9:	eb da                	jmp    801036a5 <exit+0x28>
  begin_op();
801036cb:	e8 a3 f1 ff ff       	call   80102873 <begin_op>
  iput(curproc->cwd);
801036d0:	83 ec 0c             	sub    $0xc,%esp
801036d3:	ff 76 68             	pushl  0x68(%esi)
801036d6:	e8 b9 df ff ff       	call   80101694 <iput>
  end_op();
801036db:	e8 0d f2 ff ff       	call   801028ed <end_op>
  curproc->cwd = 0;
801036e0:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801036e7:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801036ee:	e8 7d 05 00 00       	call   80103c70 <acquire>
  wakeup1(curproc->parent);
801036f3:	8b 46 14             	mov    0x14(%esi),%eax
801036f6:	e8 0d fa ff ff       	call   80103108 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036fb:	83 c4 10             	add    $0x10,%esp
801036fe:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
80103703:	eb 03                	jmp    80103708 <exit+0x8b>
80103705:	83 c3 7c             	add    $0x7c,%ebx
80103708:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
8010370e:	73 1a                	jae    8010372a <exit+0xad>
    if(p->parent == curproc){
80103710:	39 73 14             	cmp    %esi,0x14(%ebx)
80103713:	75 f0                	jne    80103705 <exit+0x88>
      p->parent = initproc;
80103715:	a1 bc 95 12 80       	mov    0x801295bc,%eax
8010371a:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010371d:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103721:	75 e2                	jne    80103705 <exit+0x88>
        wakeup1(initproc);
80103723:	e8 e0 f9 ff ff       	call   80103108 <wakeup1>
80103728:	eb db                	jmp    80103705 <exit+0x88>
  curproc->state = ZOMBIE;
8010372a:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103731:	e8 a4 fe ff ff       	call   801035da <sched>
  panic("zombie exit");
80103736:	83 ec 0c             	sub    $0xc,%esp
80103739:	68 7d 6b 10 80       	push   $0x80106b7d
8010373e:	e8 05 cc ff ff       	call   80100348 <panic>

80103743 <yield>:
{
80103743:	55                   	push   %ebp
80103744:	89 e5                	mov    %esp,%ebp
80103746:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103749:	68 40 1d 13 80       	push   $0x80131d40
8010374e:	e8 1d 05 00 00       	call   80103c70 <acquire>
  myproc()->state = RUNNABLE;
80103753:	e8 76 fb ff ff       	call   801032ce <myproc>
80103758:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010375f:	e8 76 fe ff ff       	call   801035da <sched>
  release(&ptable.lock);
80103764:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
8010376b:	e8 65 05 00 00       	call   80103cd5 <release>
}
80103770:	83 c4 10             	add    $0x10,%esp
80103773:	c9                   	leave  
80103774:	c3                   	ret    

80103775 <sleep>:
{
80103775:	55                   	push   %ebp
80103776:	89 e5                	mov    %esp,%ebp
80103778:	56                   	push   %esi
80103779:	53                   	push   %ebx
8010377a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
8010377d:	e8 4c fb ff ff       	call   801032ce <myproc>
  if(p == 0)
80103782:	85 c0                	test   %eax,%eax
80103784:	74 66                	je     801037ec <sleep+0x77>
80103786:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103788:	85 db                	test   %ebx,%ebx
8010378a:	74 6d                	je     801037f9 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010378c:	81 fb 40 1d 13 80    	cmp    $0x80131d40,%ebx
80103792:	74 18                	je     801037ac <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	68 40 1d 13 80       	push   $0x80131d40
8010379c:	e8 cf 04 00 00       	call   80103c70 <acquire>
    release(lk);
801037a1:	89 1c 24             	mov    %ebx,(%esp)
801037a4:	e8 2c 05 00 00       	call   80103cd5 <release>
801037a9:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801037ac:	8b 45 08             	mov    0x8(%ebp),%eax
801037af:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801037b2:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801037b9:	e8 1c fe ff ff       	call   801035da <sched>
  p->chan = 0;
801037be:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801037c5:	81 fb 40 1d 13 80    	cmp    $0x80131d40,%ebx
801037cb:	74 18                	je     801037e5 <sleep+0x70>
    release(&ptable.lock);
801037cd:	83 ec 0c             	sub    $0xc,%esp
801037d0:	68 40 1d 13 80       	push   $0x80131d40
801037d5:	e8 fb 04 00 00       	call   80103cd5 <release>
    acquire(lk);
801037da:	89 1c 24             	mov    %ebx,(%esp)
801037dd:	e8 8e 04 00 00       	call   80103c70 <acquire>
801037e2:	83 c4 10             	add    $0x10,%esp
}
801037e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037e8:	5b                   	pop    %ebx
801037e9:	5e                   	pop    %esi
801037ea:	5d                   	pop    %ebp
801037eb:	c3                   	ret    
    panic("sleep");
801037ec:	83 ec 0c             	sub    $0xc,%esp
801037ef:	68 89 6b 10 80       	push   $0x80106b89
801037f4:	e8 4f cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801037f9:	83 ec 0c             	sub    $0xc,%esp
801037fc:	68 8f 6b 10 80       	push   $0x80106b8f
80103801:	e8 42 cb ff ff       	call   80100348 <panic>

80103806 <wait>:
{
80103806:	55                   	push   %ebp
80103807:	89 e5                	mov    %esp,%ebp
80103809:	56                   	push   %esi
8010380a:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010380b:	e8 be fa ff ff       	call   801032ce <myproc>
80103810:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103812:	83 ec 0c             	sub    $0xc,%esp
80103815:	68 40 1d 13 80       	push   $0x80131d40
8010381a:	e8 51 04 00 00       	call   80103c70 <acquire>
8010381f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103822:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103827:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
8010382c:	eb 5b                	jmp    80103889 <wait+0x83>
        pid = p->pid;
8010382e:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103831:	83 ec 0c             	sub    $0xc,%esp
80103834:	ff 73 08             	pushl  0x8(%ebx)
80103837:	e8 74 e7 ff ff       	call   80101fb0 <kfree>
        p->kstack = 0;
8010383c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103843:	83 c4 04             	add    $0x4,%esp
80103846:	ff 73 04             	pushl  0x4(%ebx)
80103849:	e8 6e 2a 00 00       	call   801062bc <freevm>
        p->pid = 0;
8010384e:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103855:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010385c:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103860:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103867:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010386e:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103875:	e8 5b 04 00 00       	call   80103cd5 <release>
        return pid;
8010387a:	83 c4 10             	add    $0x10,%esp
}
8010387d:	89 f0                	mov    %esi,%eax
8010387f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103882:	5b                   	pop    %ebx
80103883:	5e                   	pop    %esi
80103884:	5d                   	pop    %ebp
80103885:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103886:	83 c3 7c             	add    $0x7c,%ebx
80103889:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
8010388f:	73 12                	jae    801038a3 <wait+0x9d>
      if(p->parent != curproc)
80103891:	39 73 14             	cmp    %esi,0x14(%ebx)
80103894:	75 f0                	jne    80103886 <wait+0x80>
      if(p->state == ZOMBIE){
80103896:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010389a:	74 92                	je     8010382e <wait+0x28>
      havekids = 1;
8010389c:	b8 01 00 00 00       	mov    $0x1,%eax
801038a1:	eb e3                	jmp    80103886 <wait+0x80>
    if(!havekids || curproc->killed){
801038a3:	85 c0                	test   %eax,%eax
801038a5:	74 06                	je     801038ad <wait+0xa7>
801038a7:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801038ab:	74 17                	je     801038c4 <wait+0xbe>
      release(&ptable.lock);
801038ad:	83 ec 0c             	sub    $0xc,%esp
801038b0:	68 40 1d 13 80       	push   $0x80131d40
801038b5:	e8 1b 04 00 00       	call   80103cd5 <release>
      return -1;
801038ba:	83 c4 10             	add    $0x10,%esp
801038bd:	be ff ff ff ff       	mov    $0xffffffff,%esi
801038c2:	eb b9                	jmp    8010387d <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801038c4:	83 ec 08             	sub    $0x8,%esp
801038c7:	68 40 1d 13 80       	push   $0x80131d40
801038cc:	56                   	push   %esi
801038cd:	e8 a3 fe ff ff       	call   80103775 <sleep>
    havekids = 0;
801038d2:	83 c4 10             	add    $0x10,%esp
801038d5:	e9 48 ff ff ff       	jmp    80103822 <wait+0x1c>

801038da <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801038da:	55                   	push   %ebp
801038db:	89 e5                	mov    %esp,%ebp
801038dd:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801038e0:	68 40 1d 13 80       	push   $0x80131d40
801038e5:	e8 86 03 00 00       	call   80103c70 <acquire>
  wakeup1(chan);
801038ea:	8b 45 08             	mov    0x8(%ebp),%eax
801038ed:	e8 16 f8 ff ff       	call   80103108 <wakeup1>
  release(&ptable.lock);
801038f2:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801038f9:	e8 d7 03 00 00       	call   80103cd5 <release>
}
801038fe:	83 c4 10             	add    $0x10,%esp
80103901:	c9                   	leave  
80103902:	c3                   	ret    

80103903 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103903:	55                   	push   %ebp
80103904:	89 e5                	mov    %esp,%ebp
80103906:	53                   	push   %ebx
80103907:	83 ec 10             	sub    $0x10,%esp
8010390a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010390d:	68 40 1d 13 80       	push   $0x80131d40
80103912:	e8 59 03 00 00       	call   80103c70 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103917:	83 c4 10             	add    $0x10,%esp
8010391a:	b8 74 1d 13 80       	mov    $0x80131d74,%eax
8010391f:	3d 74 3c 13 80       	cmp    $0x80133c74,%eax
80103924:	73 3a                	jae    80103960 <kill+0x5d>
    if(p->pid == pid){
80103926:	39 58 10             	cmp    %ebx,0x10(%eax)
80103929:	74 05                	je     80103930 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010392b:	83 c0 7c             	add    $0x7c,%eax
8010392e:	eb ef                	jmp    8010391f <kill+0x1c>
      p->killed = 1;
80103930:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103937:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010393b:	74 1a                	je     80103957 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
8010393d:	83 ec 0c             	sub    $0xc,%esp
80103940:	68 40 1d 13 80       	push   $0x80131d40
80103945:	e8 8b 03 00 00       	call   80103cd5 <release>
      return 0;
8010394a:	83 c4 10             	add    $0x10,%esp
8010394d:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103955:	c9                   	leave  
80103956:	c3                   	ret    
        p->state = RUNNABLE;
80103957:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
8010395e:	eb dd                	jmp    8010393d <kill+0x3a>
  release(&ptable.lock);
80103960:	83 ec 0c             	sub    $0xc,%esp
80103963:	68 40 1d 13 80       	push   $0x80131d40
80103968:	e8 68 03 00 00       	call   80103cd5 <release>
  return -1;
8010396d:	83 c4 10             	add    $0x10,%esp
80103970:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103975:	eb db                	jmp    80103952 <kill+0x4f>

80103977 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103977:	55                   	push   %ebp
80103978:	89 e5                	mov    %esp,%ebp
8010397a:	56                   	push   %esi
8010397b:	53                   	push   %ebx
8010397c:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010397f:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
80103984:	eb 33                	jmp    801039b9 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103986:	b8 a0 6b 10 80       	mov    $0x80106ba0,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010398b:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010398e:	52                   	push   %edx
8010398f:	50                   	push   %eax
80103990:	ff 73 10             	pushl  0x10(%ebx)
80103993:	68 a4 6b 10 80       	push   $0x80106ba4
80103998:	e8 6e cc ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
8010399d:	83 c4 10             	add    $0x10,%esp
801039a0:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801039a4:	74 39                	je     801039df <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801039a6:	83 ec 0c             	sub    $0xc,%esp
801039a9:	68 1b 6f 10 80       	push   $0x80106f1b
801039ae:	e8 58 cc ff ff       	call   8010060b <cprintf>
801039b3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039b6:	83 c3 7c             	add    $0x7c,%ebx
801039b9:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
801039bf:	73 61                	jae    80103a22 <procdump+0xab>
    if(p->state == UNUSED)
801039c1:	8b 43 0c             	mov    0xc(%ebx),%eax
801039c4:	85 c0                	test   %eax,%eax
801039c6:	74 ee                	je     801039b6 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801039c8:	83 f8 05             	cmp    $0x5,%eax
801039cb:	77 b9                	ja     80103986 <procdump+0xf>
801039cd:	8b 04 85 00 6c 10 80 	mov    -0x7fef9400(,%eax,4),%eax
801039d4:	85 c0                	test   %eax,%eax
801039d6:	75 b3                	jne    8010398b <procdump+0x14>
      state = "???";
801039d8:	b8 a0 6b 10 80       	mov    $0x80106ba0,%eax
801039dd:	eb ac                	jmp    8010398b <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801039df:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039e2:	8b 40 0c             	mov    0xc(%eax),%eax
801039e5:	83 c0 08             	add    $0x8,%eax
801039e8:	83 ec 08             	sub    $0x8,%esp
801039eb:	8d 55 d0             	lea    -0x30(%ebp),%edx
801039ee:	52                   	push   %edx
801039ef:	50                   	push   %eax
801039f0:	e8 5a 01 00 00       	call   80103b4f <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801039f5:	83 c4 10             	add    $0x10,%esp
801039f8:	be 00 00 00 00       	mov    $0x0,%esi
801039fd:	eb 14                	jmp    80103a13 <procdump+0x9c>
        cprintf(" %p", pc[i]);
801039ff:	83 ec 08             	sub    $0x8,%esp
80103a02:	50                   	push   %eax
80103a03:	68 e1 65 10 80       	push   $0x801065e1
80103a08:	e8 fe cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a0d:	83 c6 01             	add    $0x1,%esi
80103a10:	83 c4 10             	add    $0x10,%esp
80103a13:	83 fe 09             	cmp    $0x9,%esi
80103a16:	7f 8e                	jg     801039a6 <procdump+0x2f>
80103a18:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a1c:	85 c0                	test   %eax,%eax
80103a1e:	75 df                	jne    801039ff <procdump+0x88>
80103a20:	eb 84                	jmp    801039a6 <procdump+0x2f>
  }
}
80103a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a25:	5b                   	pop    %ebx
80103a26:	5e                   	pop    %esi
80103a27:	5d                   	pop    %ebp
80103a28:	c3                   	ret    

80103a29 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103a29:	55                   	push   %ebp
80103a2a:	89 e5                	mov    %esp,%ebp
80103a2c:	53                   	push   %ebx
80103a2d:	83 ec 0c             	sub    $0xc,%esp
80103a30:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a33:	68 18 6c 10 80       	push   $0x80106c18
80103a38:	8d 43 04             	lea    0x4(%ebx),%eax
80103a3b:	50                   	push   %eax
80103a3c:	e8 f3 00 00 00       	call   80103b34 <initlock>
  lk->name = name;
80103a41:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a44:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a4d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a54:	83 c4 10             	add    $0x10,%esp
80103a57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a5a:	c9                   	leave  
80103a5b:	c3                   	ret    

80103a5c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a5c:	55                   	push   %ebp
80103a5d:	89 e5                	mov    %esp,%ebp
80103a5f:	56                   	push   %esi
80103a60:	53                   	push   %ebx
80103a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a64:	8d 73 04             	lea    0x4(%ebx),%esi
80103a67:	83 ec 0c             	sub    $0xc,%esp
80103a6a:	56                   	push   %esi
80103a6b:	e8 00 02 00 00       	call   80103c70 <acquire>
  while (lk->locked) {
80103a70:	83 c4 10             	add    $0x10,%esp
80103a73:	eb 0d                	jmp    80103a82 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103a75:	83 ec 08             	sub    $0x8,%esp
80103a78:	56                   	push   %esi
80103a79:	53                   	push   %ebx
80103a7a:	e8 f6 fc ff ff       	call   80103775 <sleep>
80103a7f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103a82:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a85:	75 ee                	jne    80103a75 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103a87:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103a8d:	e8 3c f8 ff ff       	call   801032ce <myproc>
80103a92:	8b 40 10             	mov    0x10(%eax),%eax
80103a95:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103a98:	83 ec 0c             	sub    $0xc,%esp
80103a9b:	56                   	push   %esi
80103a9c:	e8 34 02 00 00       	call   80103cd5 <release>
}
80103aa1:	83 c4 10             	add    $0x10,%esp
80103aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103aa7:	5b                   	pop    %ebx
80103aa8:	5e                   	pop    %esi
80103aa9:	5d                   	pop    %ebp
80103aaa:	c3                   	ret    

80103aab <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103aab:	55                   	push   %ebp
80103aac:	89 e5                	mov    %esp,%ebp
80103aae:	56                   	push   %esi
80103aaf:	53                   	push   %ebx
80103ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103ab3:	8d 73 04             	lea    0x4(%ebx),%esi
80103ab6:	83 ec 0c             	sub    $0xc,%esp
80103ab9:	56                   	push   %esi
80103aba:	e8 b1 01 00 00       	call   80103c70 <acquire>
  lk->locked = 0;
80103abf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ac5:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103acc:	89 1c 24             	mov    %ebx,(%esp)
80103acf:	e8 06 fe ff ff       	call   801038da <wakeup>
  release(&lk->lk);
80103ad4:	89 34 24             	mov    %esi,(%esp)
80103ad7:	e8 f9 01 00 00       	call   80103cd5 <release>
}
80103adc:	83 c4 10             	add    $0x10,%esp
80103adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ae2:	5b                   	pop    %ebx
80103ae3:	5e                   	pop    %esi
80103ae4:	5d                   	pop    %ebp
80103ae5:	c3                   	ret    

80103ae6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ae6:	55                   	push   %ebp
80103ae7:	89 e5                	mov    %esp,%ebp
80103ae9:	56                   	push   %esi
80103aea:	53                   	push   %ebx
80103aeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103aee:	8d 73 04             	lea    0x4(%ebx),%esi
80103af1:	83 ec 0c             	sub    $0xc,%esp
80103af4:	56                   	push   %esi
80103af5:	e8 76 01 00 00       	call   80103c70 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103afa:	83 c4 10             	add    $0x10,%esp
80103afd:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b00:	75 17                	jne    80103b19 <holdingsleep+0x33>
80103b02:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103b07:	83 ec 0c             	sub    $0xc,%esp
80103b0a:	56                   	push   %esi
80103b0b:	e8 c5 01 00 00       	call   80103cd5 <release>
  return r;
}
80103b10:	89 d8                	mov    %ebx,%eax
80103b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b15:	5b                   	pop    %ebx
80103b16:	5e                   	pop    %esi
80103b17:	5d                   	pop    %ebp
80103b18:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103b19:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103b1c:	e8 ad f7 ff ff       	call   801032ce <myproc>
80103b21:	3b 58 10             	cmp    0x10(%eax),%ebx
80103b24:	74 07                	je     80103b2d <holdingsleep+0x47>
80103b26:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b2b:	eb da                	jmp    80103b07 <holdingsleep+0x21>
80103b2d:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b32:	eb d3                	jmp    80103b07 <holdingsleep+0x21>

80103b34 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b34:	55                   	push   %ebp
80103b35:	89 e5                	mov    %esp,%ebp
80103b37:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b3d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b4d:	5d                   	pop    %ebp
80103b4e:	c3                   	ret    

80103b4f <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b4f:	55                   	push   %ebp
80103b50:	89 e5                	mov    %esp,%ebp
80103b52:	53                   	push   %ebx
80103b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b56:	8b 45 08             	mov    0x8(%ebp),%eax
80103b59:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b5c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b61:	83 f8 09             	cmp    $0x9,%eax
80103b64:	7f 25                	jg     80103b8b <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b66:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b6c:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b72:	77 17                	ja     80103b8b <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b74:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b77:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b7a:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b7c:	83 c0 01             	add    $0x1,%eax
80103b7f:	eb e0                	jmp    80103b61 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b81:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b88:	83 c0 01             	add    $0x1,%eax
80103b8b:	83 f8 09             	cmp    $0x9,%eax
80103b8e:	7e f1                	jle    80103b81 <getcallerpcs+0x32>
}
80103b90:	5b                   	pop    %ebx
80103b91:	5d                   	pop    %ebp
80103b92:	c3                   	ret    

80103b93 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b93:	55                   	push   %ebp
80103b94:	89 e5                	mov    %esp,%ebp
80103b96:	53                   	push   %ebx
80103b97:	83 ec 04             	sub    $0x4,%esp
80103b9a:	9c                   	pushf  
80103b9b:	5b                   	pop    %ebx
  asm volatile("cli");
80103b9c:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b9d:	e8 b5 f6 ff ff       	call   80103257 <mycpu>
80103ba2:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103ba9:	74 12                	je     80103bbd <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103bab:	e8 a7 f6 ff ff       	call   80103257 <mycpu>
80103bb0:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103bb7:	83 c4 04             	add    $0x4,%esp
80103bba:	5b                   	pop    %ebx
80103bbb:	5d                   	pop    %ebp
80103bbc:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103bbd:	e8 95 f6 ff ff       	call   80103257 <mycpu>
80103bc2:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103bc8:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103bce:	eb db                	jmp    80103bab <pushcli+0x18>

80103bd0 <popcli>:

void
popcli(void)
{
80103bd0:	55                   	push   %ebp
80103bd1:	89 e5                	mov    %esp,%ebp
80103bd3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103bd6:	9c                   	pushf  
80103bd7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103bd8:	f6 c4 02             	test   $0x2,%ah
80103bdb:	75 28                	jne    80103c05 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103bdd:	e8 75 f6 ff ff       	call   80103257 <mycpu>
80103be2:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103be8:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103beb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103bf1:	85 d2                	test   %edx,%edx
80103bf3:	78 1d                	js     80103c12 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bf5:	e8 5d f6 ff ff       	call   80103257 <mycpu>
80103bfa:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c01:	74 1c                	je     80103c1f <popcli+0x4f>
    sti();
}
80103c03:	c9                   	leave  
80103c04:	c3                   	ret    
    panic("popcli - interruptible");
80103c05:	83 ec 0c             	sub    $0xc,%esp
80103c08:	68 23 6c 10 80       	push   $0x80106c23
80103c0d:	e8 36 c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103c12:	83 ec 0c             	sub    $0xc,%esp
80103c15:	68 3a 6c 10 80       	push   $0x80106c3a
80103c1a:	e8 29 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c1f:	e8 33 f6 ff ff       	call   80103257 <mycpu>
80103c24:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c2b:	74 d6                	je     80103c03 <popcli+0x33>
  asm volatile("sti");
80103c2d:	fb                   	sti    
}
80103c2e:	eb d3                	jmp    80103c03 <popcli+0x33>

80103c30 <holding>:
{
80103c30:	55                   	push   %ebp
80103c31:	89 e5                	mov    %esp,%ebp
80103c33:	53                   	push   %ebx
80103c34:	83 ec 04             	sub    $0x4,%esp
80103c37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c3a:	e8 54 ff ff ff       	call   80103b93 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c3f:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c42:	75 12                	jne    80103c56 <holding+0x26>
80103c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c49:	e8 82 ff ff ff       	call   80103bd0 <popcli>
}
80103c4e:	89 d8                	mov    %ebx,%eax
80103c50:	83 c4 04             	add    $0x4,%esp
80103c53:	5b                   	pop    %ebx
80103c54:	5d                   	pop    %ebp
80103c55:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c56:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c59:	e8 f9 f5 ff ff       	call   80103257 <mycpu>
80103c5e:	39 c3                	cmp    %eax,%ebx
80103c60:	74 07                	je     80103c69 <holding+0x39>
80103c62:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c67:	eb e0                	jmp    80103c49 <holding+0x19>
80103c69:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c6e:	eb d9                	jmp    80103c49 <holding+0x19>

80103c70 <acquire>:
{
80103c70:	55                   	push   %ebp
80103c71:	89 e5                	mov    %esp,%ebp
80103c73:	53                   	push   %ebx
80103c74:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c77:	e8 17 ff ff ff       	call   80103b93 <pushcli>
  if(holding(lk))
80103c7c:	83 ec 0c             	sub    $0xc,%esp
80103c7f:	ff 75 08             	pushl  0x8(%ebp)
80103c82:	e8 a9 ff ff ff       	call   80103c30 <holding>
80103c87:	83 c4 10             	add    $0x10,%esp
80103c8a:	85 c0                	test   %eax,%eax
80103c8c:	75 3a                	jne    80103cc8 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103c91:	b8 01 00 00 00       	mov    $0x1,%eax
80103c96:	f0 87 02             	lock xchg %eax,(%edx)
80103c99:	85 c0                	test   %eax,%eax
80103c9b:	75 f1                	jne    80103c8e <acquire+0x1e>
  __sync_synchronize();
80103c9d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103ca2:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103ca5:	e8 ad f5 ff ff       	call   80103257 <mycpu>
80103caa:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103cad:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb0:	83 c0 0c             	add    $0xc,%eax
80103cb3:	83 ec 08             	sub    $0x8,%esp
80103cb6:	50                   	push   %eax
80103cb7:	8d 45 08             	lea    0x8(%ebp),%eax
80103cba:	50                   	push   %eax
80103cbb:	e8 8f fe ff ff       	call   80103b4f <getcallerpcs>
}
80103cc0:	83 c4 10             	add    $0x10,%esp
80103cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cc6:	c9                   	leave  
80103cc7:	c3                   	ret    
    panic("acquire");
80103cc8:	83 ec 0c             	sub    $0xc,%esp
80103ccb:	68 41 6c 10 80       	push   $0x80106c41
80103cd0:	e8 73 c6 ff ff       	call   80100348 <panic>

80103cd5 <release>:
{
80103cd5:	55                   	push   %ebp
80103cd6:	89 e5                	mov    %esp,%ebp
80103cd8:	53                   	push   %ebx
80103cd9:	83 ec 10             	sub    $0x10,%esp
80103cdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103cdf:	53                   	push   %ebx
80103ce0:	e8 4b ff ff ff       	call   80103c30 <holding>
80103ce5:	83 c4 10             	add    $0x10,%esp
80103ce8:	85 c0                	test   %eax,%eax
80103cea:	74 23                	je     80103d0f <release+0x3a>
  lk->pcs[0] = 0;
80103cec:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103cf3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103cfa:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103cff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103d05:	e8 c6 fe ff ff       	call   80103bd0 <popcli>
}
80103d0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d0d:	c9                   	leave  
80103d0e:	c3                   	ret    
    panic("release");
80103d0f:	83 ec 0c             	sub    $0xc,%esp
80103d12:	68 49 6c 10 80       	push   $0x80106c49
80103d17:	e8 2c c6 ff ff       	call   80100348 <panic>

80103d1c <memset>:
80103d1c:	55                   	push   %ebp
80103d1d:	89 e5                	mov    %esp,%ebp
80103d1f:	57                   	push   %edi
80103d20:	53                   	push   %ebx
80103d21:	8b 55 08             	mov    0x8(%ebp),%edx
80103d24:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103d27:	f6 c2 03             	test   $0x3,%dl
80103d2a:	75 05                	jne    80103d31 <memset+0x15>
80103d2c:	f6 c1 03             	test   $0x3,%cl
80103d2f:	74 0e                	je     80103d3f <memset+0x23>
80103d31:	89 d7                	mov    %edx,%edi
80103d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d36:	fc                   	cld    
80103d37:	f3 aa                	rep stos %al,%es:(%edi)
80103d39:	89 d0                	mov    %edx,%eax
80103d3b:	5b                   	pop    %ebx
80103d3c:	5f                   	pop    %edi
80103d3d:	5d                   	pop    %ebp
80103d3e:	c3                   	ret    
80103d3f:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
80103d43:	c1 e9 02             	shr    $0x2,%ecx
80103d46:	89 f8                	mov    %edi,%eax
80103d48:	c1 e0 18             	shl    $0x18,%eax
80103d4b:	89 fb                	mov    %edi,%ebx
80103d4d:	c1 e3 10             	shl    $0x10,%ebx
80103d50:	09 d8                	or     %ebx,%eax
80103d52:	89 fb                	mov    %edi,%ebx
80103d54:	c1 e3 08             	shl    $0x8,%ebx
80103d57:	09 d8                	or     %ebx,%eax
80103d59:	09 f8                	or     %edi,%eax
80103d5b:	89 d7                	mov    %edx,%edi
80103d5d:	fc                   	cld    
80103d5e:	f3 ab                	rep stos %eax,%es:(%edi)
80103d60:	eb d7                	jmp    80103d39 <memset+0x1d>

80103d62 <memcmp>:
80103d62:	55                   	push   %ebp
80103d63:	89 e5                	mov    %esp,%ebp
80103d65:	56                   	push   %esi
80103d66:	53                   	push   %ebx
80103d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d6d:	8b 45 10             	mov    0x10(%ebp),%eax
80103d70:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d73:	85 c0                	test   %eax,%eax
80103d75:	74 1c                	je     80103d93 <memcmp+0x31>
80103d77:	0f b6 01             	movzbl (%ecx),%eax
80103d7a:	0f b6 1a             	movzbl (%edx),%ebx
80103d7d:	38 d8                	cmp    %bl,%al
80103d7f:	75 0a                	jne    80103d8b <memcmp+0x29>
80103d81:	83 c1 01             	add    $0x1,%ecx
80103d84:	83 c2 01             	add    $0x1,%edx
80103d87:	89 f0                	mov    %esi,%eax
80103d89:	eb e5                	jmp    80103d70 <memcmp+0xe>
80103d8b:	0f b6 c0             	movzbl %al,%eax
80103d8e:	0f b6 db             	movzbl %bl,%ebx
80103d91:	29 d8                	sub    %ebx,%eax
80103d93:	5b                   	pop    %ebx
80103d94:	5e                   	pop    %esi
80103d95:	5d                   	pop    %ebp
80103d96:	c3                   	ret    

80103d97 <memmove>:
80103d97:	55                   	push   %ebp
80103d98:	89 e5                	mov    %esp,%ebp
80103d9a:	56                   	push   %esi
80103d9b:	53                   	push   %ebx
80103d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103da2:	8b 55 10             	mov    0x10(%ebp),%edx
80103da5:	39 c1                	cmp    %eax,%ecx
80103da7:	73 3a                	jae    80103de3 <memmove+0x4c>
80103da9:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103dac:	39 c3                	cmp    %eax,%ebx
80103dae:	76 37                	jbe    80103de7 <memmove+0x50>
80103db0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80103db3:	eb 0d                	jmp    80103dc2 <memmove+0x2b>
80103db5:	83 eb 01             	sub    $0x1,%ebx
80103db8:	83 e9 01             	sub    $0x1,%ecx
80103dbb:	0f b6 13             	movzbl (%ebx),%edx
80103dbe:	88 11                	mov    %dl,(%ecx)
80103dc0:	89 f2                	mov    %esi,%edx
80103dc2:	8d 72 ff             	lea    -0x1(%edx),%esi
80103dc5:	85 d2                	test   %edx,%edx
80103dc7:	75 ec                	jne    80103db5 <memmove+0x1e>
80103dc9:	eb 14                	jmp    80103ddf <memmove+0x48>
80103dcb:	0f b6 11             	movzbl (%ecx),%edx
80103dce:	88 13                	mov    %dl,(%ebx)
80103dd0:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103dd3:	8d 49 01             	lea    0x1(%ecx),%ecx
80103dd6:	89 f2                	mov    %esi,%edx
80103dd8:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ddb:	85 d2                	test   %edx,%edx
80103ddd:	75 ec                	jne    80103dcb <memmove+0x34>
80103ddf:	5b                   	pop    %ebx
80103de0:	5e                   	pop    %esi
80103de1:	5d                   	pop    %ebp
80103de2:	c3                   	ret    
80103de3:	89 c3                	mov    %eax,%ebx
80103de5:	eb f1                	jmp    80103dd8 <memmove+0x41>
80103de7:	89 c3                	mov    %eax,%ebx
80103de9:	eb ed                	jmp    80103dd8 <memmove+0x41>

80103deb <memcpy>:
80103deb:	55                   	push   %ebp
80103dec:	89 e5                	mov    %esp,%ebp
80103dee:	ff 75 10             	pushl  0x10(%ebp)
80103df1:	ff 75 0c             	pushl  0xc(%ebp)
80103df4:	ff 75 08             	pushl  0x8(%ebp)
80103df7:	e8 9b ff ff ff       	call   80103d97 <memmove>
80103dfc:	c9                   	leave  
80103dfd:	c3                   	ret    

80103dfe <strncmp>:
80103dfe:	55                   	push   %ebp
80103dff:	89 e5                	mov    %esp,%ebp
80103e01:	53                   	push   %ebx
80103e02:	8b 55 08             	mov    0x8(%ebp),%edx
80103e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e08:	8b 45 10             	mov    0x10(%ebp),%eax
80103e0b:	eb 09                	jmp    80103e16 <strncmp+0x18>
80103e0d:	83 e8 01             	sub    $0x1,%eax
80103e10:	83 c2 01             	add    $0x1,%edx
80103e13:	83 c1 01             	add    $0x1,%ecx
80103e16:	85 c0                	test   %eax,%eax
80103e18:	74 0b                	je     80103e25 <strncmp+0x27>
80103e1a:	0f b6 1a             	movzbl (%edx),%ebx
80103e1d:	84 db                	test   %bl,%bl
80103e1f:	74 04                	je     80103e25 <strncmp+0x27>
80103e21:	3a 19                	cmp    (%ecx),%bl
80103e23:	74 e8                	je     80103e0d <strncmp+0xf>
80103e25:	85 c0                	test   %eax,%eax
80103e27:	74 0b                	je     80103e34 <strncmp+0x36>
80103e29:	0f b6 02             	movzbl (%edx),%eax
80103e2c:	0f b6 11             	movzbl (%ecx),%edx
80103e2f:	29 d0                	sub    %edx,%eax
80103e31:	5b                   	pop    %ebx
80103e32:	5d                   	pop    %ebp
80103e33:	c3                   	ret    
80103e34:	b8 00 00 00 00       	mov    $0x0,%eax
80103e39:	eb f6                	jmp    80103e31 <strncmp+0x33>

80103e3b <strncpy>:
80103e3b:	55                   	push   %ebp
80103e3c:	89 e5                	mov    %esp,%ebp
80103e3e:	57                   	push   %edi
80103e3f:	56                   	push   %esi
80103e40:	53                   	push   %ebx
80103e41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e44:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103e47:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4a:	eb 04                	jmp    80103e50 <strncpy+0x15>
80103e4c:	89 fb                	mov    %edi,%ebx
80103e4e:	89 f0                	mov    %esi,%eax
80103e50:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e53:	85 c9                	test   %ecx,%ecx
80103e55:	7e 1d                	jle    80103e74 <strncpy+0x39>
80103e57:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e5a:	8d 70 01             	lea    0x1(%eax),%esi
80103e5d:	0f b6 1b             	movzbl (%ebx),%ebx
80103e60:	88 18                	mov    %bl,(%eax)
80103e62:	89 d1                	mov    %edx,%ecx
80103e64:	84 db                	test   %bl,%bl
80103e66:	75 e4                	jne    80103e4c <strncpy+0x11>
80103e68:	89 f0                	mov    %esi,%eax
80103e6a:	eb 08                	jmp    80103e74 <strncpy+0x39>
80103e6c:	c6 00 00             	movb   $0x0,(%eax)
80103e6f:	89 ca                	mov    %ecx,%edx
80103e71:	8d 40 01             	lea    0x1(%eax),%eax
80103e74:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e77:	85 d2                	test   %edx,%edx
80103e79:	7f f1                	jg     80103e6c <strncpy+0x31>
80103e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7e:	5b                   	pop    %ebx
80103e7f:	5e                   	pop    %esi
80103e80:	5f                   	pop    %edi
80103e81:	5d                   	pop    %ebp
80103e82:	c3                   	ret    

80103e83 <safestrcpy>:
80103e83:	55                   	push   %ebp
80103e84:	89 e5                	mov    %esp,%ebp
80103e86:	57                   	push   %edi
80103e87:	56                   	push   %esi
80103e88:	53                   	push   %ebx
80103e89:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e8f:	8b 55 10             	mov    0x10(%ebp),%edx
80103e92:	85 d2                	test   %edx,%edx
80103e94:	7e 23                	jle    80103eb9 <safestrcpy+0x36>
80103e96:	89 c1                	mov    %eax,%ecx
80103e98:	eb 04                	jmp    80103e9e <safestrcpy+0x1b>
80103e9a:	89 fb                	mov    %edi,%ebx
80103e9c:	89 f1                	mov    %esi,%ecx
80103e9e:	83 ea 01             	sub    $0x1,%edx
80103ea1:	85 d2                	test   %edx,%edx
80103ea3:	7e 11                	jle    80103eb6 <safestrcpy+0x33>
80103ea5:	8d 7b 01             	lea    0x1(%ebx),%edi
80103ea8:	8d 71 01             	lea    0x1(%ecx),%esi
80103eab:	0f b6 1b             	movzbl (%ebx),%ebx
80103eae:	88 19                	mov    %bl,(%ecx)
80103eb0:	84 db                	test   %bl,%bl
80103eb2:	75 e6                	jne    80103e9a <safestrcpy+0x17>
80103eb4:	89 f1                	mov    %esi,%ecx
80103eb6:	c6 01 00             	movb   $0x0,(%ecx)
80103eb9:	5b                   	pop    %ebx
80103eba:	5e                   	pop    %esi
80103ebb:	5f                   	pop    %edi
80103ebc:	5d                   	pop    %ebp
80103ebd:	c3                   	ret    

80103ebe <strlen>:
80103ebe:	55                   	push   %ebp
80103ebf:	89 e5                	mov    %esp,%ebp
80103ec1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ec4:	b8 00 00 00 00       	mov    $0x0,%eax
80103ec9:	eb 03                	jmp    80103ece <strlen+0x10>
80103ecb:	83 c0 01             	add    $0x1,%eax
80103ece:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103ed2:	75 f7                	jne    80103ecb <strlen+0xd>
80103ed4:	5d                   	pop    %ebp
80103ed5:	c3                   	ret    

80103ed6 <swtch>:
80103ed6:	8b 44 24 04          	mov    0x4(%esp),%eax
80103eda:	8b 54 24 08          	mov    0x8(%esp),%edx
80103ede:	55                   	push   %ebp
80103edf:	53                   	push   %ebx
80103ee0:	56                   	push   %esi
80103ee1:	57                   	push   %edi
80103ee2:	89 20                	mov    %esp,(%eax)
80103ee4:	89 d4                	mov    %edx,%esp
80103ee6:	5f                   	pop    %edi
80103ee7:	5e                   	pop    %esi
80103ee8:	5b                   	pop    %ebx
80103ee9:	5d                   	pop    %ebp
80103eea:	c3                   	ret    

80103eeb <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103eeb:	55                   	push   %ebp
80103eec:	89 e5                	mov    %esp,%ebp
80103eee:	53                   	push   %ebx
80103eef:	83 ec 04             	sub    $0x4,%esp
80103ef2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ef5:	e8 d4 f3 ff ff       	call   801032ce <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103efa:	8b 00                	mov    (%eax),%eax
80103efc:	39 d8                	cmp    %ebx,%eax
80103efe:	76 19                	jbe    80103f19 <fetchint+0x2e>
80103f00:	8d 53 04             	lea    0x4(%ebx),%edx
80103f03:	39 d0                	cmp    %edx,%eax
80103f05:	72 19                	jb     80103f20 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103f07:	8b 13                	mov    (%ebx),%edx
80103f09:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f0c:	89 10                	mov    %edx,(%eax)
  return 0;
80103f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f13:	83 c4 04             	add    $0x4,%esp
80103f16:	5b                   	pop    %ebx
80103f17:	5d                   	pop    %ebp
80103f18:	c3                   	ret    
    return -1;
80103f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f1e:	eb f3                	jmp    80103f13 <fetchint+0x28>
80103f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f25:	eb ec                	jmp    80103f13 <fetchint+0x28>

80103f27 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103f27:	55                   	push   %ebp
80103f28:	89 e5                	mov    %esp,%ebp
80103f2a:	53                   	push   %ebx
80103f2b:	83 ec 04             	sub    $0x4,%esp
80103f2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f31:	e8 98 f3 ff ff       	call   801032ce <myproc>

  if(addr >= curproc->sz)
80103f36:	39 18                	cmp    %ebx,(%eax)
80103f38:	76 26                	jbe    80103f60 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f3d:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f3f:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103f41:	89 d8                	mov    %ebx,%eax
80103f43:	39 d0                	cmp    %edx,%eax
80103f45:	73 0e                	jae    80103f55 <fetchstr+0x2e>
    if(*s == 0)
80103f47:	80 38 00             	cmpb   $0x0,(%eax)
80103f4a:	74 05                	je     80103f51 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103f4c:	83 c0 01             	add    $0x1,%eax
80103f4f:	eb f2                	jmp    80103f43 <fetchstr+0x1c>
      return s - *pp;
80103f51:	29 d8                	sub    %ebx,%eax
80103f53:	eb 05                	jmp    80103f5a <fetchstr+0x33>
  }
  return -1;
80103f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f5a:	83 c4 04             	add    $0x4,%esp
80103f5d:	5b                   	pop    %ebx
80103f5e:	5d                   	pop    %ebp
80103f5f:	c3                   	ret    
    return -1;
80103f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f65:	eb f3                	jmp    80103f5a <fetchstr+0x33>

80103f67 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f67:	55                   	push   %ebp
80103f68:	89 e5                	mov    %esp,%ebp
80103f6a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f6d:	e8 5c f3 ff ff       	call   801032ce <myproc>
80103f72:	8b 50 18             	mov    0x18(%eax),%edx
80103f75:	8b 45 08             	mov    0x8(%ebp),%eax
80103f78:	c1 e0 02             	shl    $0x2,%eax
80103f7b:	03 42 44             	add    0x44(%edx),%eax
80103f7e:	83 ec 08             	sub    $0x8,%esp
80103f81:	ff 75 0c             	pushl  0xc(%ebp)
80103f84:	83 c0 04             	add    $0x4,%eax
80103f87:	50                   	push   %eax
80103f88:	e8 5e ff ff ff       	call   80103eeb <fetchint>
}
80103f8d:	c9                   	leave  
80103f8e:	c3                   	ret    

80103f8f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f8f:	55                   	push   %ebp
80103f90:	89 e5                	mov    %esp,%ebp
80103f92:	56                   	push   %esi
80103f93:	53                   	push   %ebx
80103f94:	83 ec 10             	sub    $0x10,%esp
80103f97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103f9a:	e8 2f f3 ff ff       	call   801032ce <myproc>
80103f9f:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103fa1:	83 ec 08             	sub    $0x8,%esp
80103fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fa7:	50                   	push   %eax
80103fa8:	ff 75 08             	pushl  0x8(%ebp)
80103fab:	e8 b7 ff ff ff       	call   80103f67 <argint>
80103fb0:	83 c4 10             	add    $0x10,%esp
80103fb3:	85 c0                	test   %eax,%eax
80103fb5:	78 24                	js     80103fdb <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103fb7:	85 db                	test   %ebx,%ebx
80103fb9:	78 27                	js     80103fe2 <argptr+0x53>
80103fbb:	8b 16                	mov    (%esi),%edx
80103fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc0:	39 c2                	cmp    %eax,%edx
80103fc2:	76 25                	jbe    80103fe9 <argptr+0x5a>
80103fc4:	01 c3                	add    %eax,%ebx
80103fc6:	39 da                	cmp    %ebx,%edx
80103fc8:	72 26                	jb     80103ff0 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103fca:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fcd:	89 02                	mov    %eax,(%edx)
  return 0;
80103fcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fd7:	5b                   	pop    %ebx
80103fd8:	5e                   	pop    %esi
80103fd9:	5d                   	pop    %ebp
80103fda:	c3                   	ret    
    return -1;
80103fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe0:	eb f2                	jmp    80103fd4 <argptr+0x45>
    return -1;
80103fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe7:	eb eb                	jmp    80103fd4 <argptr+0x45>
80103fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fee:	eb e4                	jmp    80103fd4 <argptr+0x45>
80103ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff5:	eb dd                	jmp    80103fd4 <argptr+0x45>

80103ff7 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103ff7:	55                   	push   %ebp
80103ff8:	89 e5                	mov    %esp,%ebp
80103ffa:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103ffd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104000:	50                   	push   %eax
80104001:	ff 75 08             	pushl  0x8(%ebp)
80104004:	e8 5e ff ff ff       	call   80103f67 <argint>
80104009:	83 c4 10             	add    $0x10,%esp
8010400c:	85 c0                	test   %eax,%eax
8010400e:	78 13                	js     80104023 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104010:	83 ec 08             	sub    $0x8,%esp
80104013:	ff 75 0c             	pushl  0xc(%ebp)
80104016:	ff 75 f4             	pushl  -0xc(%ebp)
80104019:	e8 09 ff ff ff       	call   80103f27 <fetchstr>
8010401e:	83 c4 10             	add    $0x10,%esp
}
80104021:	c9                   	leave  
80104022:	c3                   	ret    
    return -1;
80104023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104028:	eb f7                	jmp    80104021 <argstr+0x2a>

8010402a <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
8010402a:	55                   	push   %ebp
8010402b:	89 e5                	mov    %esp,%ebp
8010402d:	53                   	push   %ebx
8010402e:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104031:	e8 98 f2 ff ff       	call   801032ce <myproc>
80104036:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104038:	8b 40 18             	mov    0x18(%eax),%eax
8010403b:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010403e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104041:	83 fa 15             	cmp    $0x15,%edx
80104044:	77 18                	ja     8010405e <syscall+0x34>
80104046:	8b 14 85 80 6c 10 80 	mov    -0x7fef9380(,%eax,4),%edx
8010404d:	85 d2                	test   %edx,%edx
8010404f:	74 0d                	je     8010405e <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104051:	ff d2                	call   *%edx
80104053:	8b 53 18             	mov    0x18(%ebx),%edx
80104056:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104059:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010405c:	c9                   	leave  
8010405d:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010405e:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104061:	50                   	push   %eax
80104062:	52                   	push   %edx
80104063:	ff 73 10             	pushl  0x10(%ebx)
80104066:	68 51 6c 10 80       	push   $0x80106c51
8010406b:	e8 9b c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104070:	8b 43 18             	mov    0x18(%ebx),%eax
80104073:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010407a:	83 c4 10             	add    $0x10,%esp
}
8010407d:	eb da                	jmp    80104059 <syscall+0x2f>

8010407f <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010407f:	55                   	push   %ebp
80104080:	89 e5                	mov    %esp,%ebp
80104082:	56                   	push   %esi
80104083:	53                   	push   %ebx
80104084:	83 ec 18             	sub    $0x18,%esp
80104087:	89 d6                	mov    %edx,%esi
80104089:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010408b:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010408e:	52                   	push   %edx
8010408f:	50                   	push   %eax
80104090:	e8 d2 fe ff ff       	call   80103f67 <argint>
80104095:	83 c4 10             	add    $0x10,%esp
80104098:	85 c0                	test   %eax,%eax
8010409a:	78 2e                	js     801040ca <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010409c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040a0:	77 2f                	ja     801040d1 <argfd+0x52>
801040a2:	e8 27 f2 ff ff       	call   801032ce <myproc>
801040a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040aa:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801040ae:	85 c0                	test   %eax,%eax
801040b0:	74 26                	je     801040d8 <argfd+0x59>
    return -1;
  if(pfd)
801040b2:	85 f6                	test   %esi,%esi
801040b4:	74 02                	je     801040b8 <argfd+0x39>
    *pfd = fd;
801040b6:	89 16                	mov    %edx,(%esi)
  if(pf)
801040b8:	85 db                	test   %ebx,%ebx
801040ba:	74 23                	je     801040df <argfd+0x60>
    *pf = f;
801040bc:	89 03                	mov    %eax,(%ebx)
  return 0;
801040be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040c6:	5b                   	pop    %ebx
801040c7:	5e                   	pop    %esi
801040c8:	5d                   	pop    %ebp
801040c9:	c3                   	ret    
    return -1;
801040ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cf:	eb f2                	jmp    801040c3 <argfd+0x44>
    return -1;
801040d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d6:	eb eb                	jmp    801040c3 <argfd+0x44>
801040d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040dd:	eb e4                	jmp    801040c3 <argfd+0x44>
  return 0;
801040df:	b8 00 00 00 00       	mov    $0x0,%eax
801040e4:	eb dd                	jmp    801040c3 <argfd+0x44>

801040e6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801040e6:	55                   	push   %ebp
801040e7:	89 e5                	mov    %esp,%ebp
801040e9:	53                   	push   %ebx
801040ea:	83 ec 04             	sub    $0x4,%esp
801040ed:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801040ef:	e8 da f1 ff ff       	call   801032ce <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801040f4:	ba 00 00 00 00       	mov    $0x0,%edx
801040f9:	83 fa 0f             	cmp    $0xf,%edx
801040fc:	7f 18                	jg     80104116 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801040fe:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104103:	74 05                	je     8010410a <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104105:	83 c2 01             	add    $0x1,%edx
80104108:	eb ef                	jmp    801040f9 <fdalloc+0x13>
      curproc->ofile[fd] = f;
8010410a:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
8010410e:	89 d0                	mov    %edx,%eax
80104110:	83 c4 04             	add    $0x4,%esp
80104113:	5b                   	pop    %ebx
80104114:	5d                   	pop    %ebp
80104115:	c3                   	ret    
  return -1;
80104116:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010411b:	eb f1                	jmp    8010410e <fdalloc+0x28>

8010411d <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010411d:	55                   	push   %ebp
8010411e:	89 e5                	mov    %esp,%ebp
80104120:	56                   	push   %esi
80104121:	53                   	push   %ebx
80104122:	83 ec 10             	sub    $0x10,%esp
80104125:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104127:	b8 20 00 00 00       	mov    $0x20,%eax
8010412c:	89 c6                	mov    %eax,%esi
8010412e:	39 43 58             	cmp    %eax,0x58(%ebx)
80104131:	76 2e                	jbe    80104161 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104133:	6a 10                	push   $0x10
80104135:	50                   	push   %eax
80104136:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104139:	50                   	push   %eax
8010413a:	53                   	push   %ebx
8010413b:	e8 3f d6 ff ff       	call   8010177f <readi>
80104140:	83 c4 10             	add    $0x10,%esp
80104143:	83 f8 10             	cmp    $0x10,%eax
80104146:	75 0c                	jne    80104154 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104148:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010414d:	75 1e                	jne    8010416d <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010414f:	8d 46 10             	lea    0x10(%esi),%eax
80104152:	eb d8                	jmp    8010412c <isdirempty+0xf>
      panic("isdirempty: readi");
80104154:	83 ec 0c             	sub    $0xc,%esp
80104157:	68 dc 6c 10 80       	push   $0x80106cdc
8010415c:	e8 e7 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104161:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104166:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104169:	5b                   	pop    %ebx
8010416a:	5e                   	pop    %esi
8010416b:	5d                   	pop    %ebp
8010416c:	c3                   	ret    
      return 0;
8010416d:	b8 00 00 00 00       	mov    $0x0,%eax
80104172:	eb f2                	jmp    80104166 <isdirempty+0x49>

80104174 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104174:	55                   	push   %ebp
80104175:	89 e5                	mov    %esp,%ebp
80104177:	57                   	push   %edi
80104178:	56                   	push   %esi
80104179:	53                   	push   %ebx
8010417a:	83 ec 44             	sub    $0x44,%esp
8010417d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104180:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104183:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104186:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104189:	52                   	push   %edx
8010418a:	50                   	push   %eax
8010418b:	e8 75 da ff ff       	call   80101c05 <nameiparent>
80104190:	89 c6                	mov    %eax,%esi
80104192:	83 c4 10             	add    $0x10,%esp
80104195:	85 c0                	test   %eax,%eax
80104197:	0f 84 3a 01 00 00    	je     801042d7 <create+0x163>
    return 0;
  ilock(dp);
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	50                   	push   %eax
801041a1:	e8 e7 d3 ff ff       	call   8010158d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801041a6:	83 c4 0c             	add    $0xc,%esp
801041a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801041ac:	50                   	push   %eax
801041ad:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801041b0:	50                   	push   %eax
801041b1:	56                   	push   %esi
801041b2:	e8 05 d8 ff ff       	call   801019bc <dirlookup>
801041b7:	89 c3                	mov    %eax,%ebx
801041b9:	83 c4 10             	add    $0x10,%esp
801041bc:	85 c0                	test   %eax,%eax
801041be:	74 3f                	je     801041ff <create+0x8b>
    iunlockput(dp);
801041c0:	83 ec 0c             	sub    $0xc,%esp
801041c3:	56                   	push   %esi
801041c4:	e8 6b d5 ff ff       	call   80101734 <iunlockput>
    ilock(ip);
801041c9:	89 1c 24             	mov    %ebx,(%esp)
801041cc:	e8 bc d3 ff ff       	call   8010158d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801041d1:	83 c4 10             	add    $0x10,%esp
801041d4:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801041d9:	75 11                	jne    801041ec <create+0x78>
801041db:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041e0:	75 0a                	jne    801041ec <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041e2:	89 d8                	mov    %ebx,%eax
801041e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801041e7:	5b                   	pop    %ebx
801041e8:	5e                   	pop    %esi
801041e9:	5f                   	pop    %edi
801041ea:	5d                   	pop    %ebp
801041eb:	c3                   	ret    
    iunlockput(ip);
801041ec:	83 ec 0c             	sub    $0xc,%esp
801041ef:	53                   	push   %ebx
801041f0:	e8 3f d5 ff ff       	call   80101734 <iunlockput>
    return 0;
801041f5:	83 c4 10             	add    $0x10,%esp
801041f8:	bb 00 00 00 00       	mov    $0x0,%ebx
801041fd:	eb e3                	jmp    801041e2 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801041ff:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104203:	83 ec 08             	sub    $0x8,%esp
80104206:	50                   	push   %eax
80104207:	ff 36                	pushl  (%esi)
80104209:	e8 7c d1 ff ff       	call   8010138a <ialloc>
8010420e:	89 c3                	mov    %eax,%ebx
80104210:	83 c4 10             	add    $0x10,%esp
80104213:	85 c0                	test   %eax,%eax
80104215:	74 55                	je     8010426c <create+0xf8>
  ilock(ip);
80104217:	83 ec 0c             	sub    $0xc,%esp
8010421a:	50                   	push   %eax
8010421b:	e8 6d d3 ff ff       	call   8010158d <ilock>
  ip->major = major;
80104220:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104224:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104228:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010422c:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104232:	89 1c 24             	mov    %ebx,(%esp)
80104235:	e8 f2 d1 ff ff       	call   8010142c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010423a:	83 c4 10             	add    $0x10,%esp
8010423d:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104242:	74 35                	je     80104279 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104244:	83 ec 04             	sub    $0x4,%esp
80104247:	ff 73 04             	pushl  0x4(%ebx)
8010424a:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010424d:	50                   	push   %eax
8010424e:	56                   	push   %esi
8010424f:	e8 e8 d8 ff ff       	call   80101b3c <dirlink>
80104254:	83 c4 10             	add    $0x10,%esp
80104257:	85 c0                	test   %eax,%eax
80104259:	78 6f                	js     801042ca <create+0x156>
  iunlockput(dp);
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	56                   	push   %esi
8010425f:	e8 d0 d4 ff ff       	call   80101734 <iunlockput>
  return ip;
80104264:	83 c4 10             	add    $0x10,%esp
80104267:	e9 76 ff ff ff       	jmp    801041e2 <create+0x6e>
    panic("create: ialloc");
8010426c:	83 ec 0c             	sub    $0xc,%esp
8010426f:	68 ee 6c 10 80       	push   $0x80106cee
80104274:	e8 cf c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104279:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010427d:	83 c0 01             	add    $0x1,%eax
80104280:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104284:	83 ec 0c             	sub    $0xc,%esp
80104287:	56                   	push   %esi
80104288:	e8 9f d1 ff ff       	call   8010142c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010428d:	83 c4 0c             	add    $0xc,%esp
80104290:	ff 73 04             	pushl  0x4(%ebx)
80104293:	68 fe 6c 10 80       	push   $0x80106cfe
80104298:	53                   	push   %ebx
80104299:	e8 9e d8 ff ff       	call   80101b3c <dirlink>
8010429e:	83 c4 10             	add    $0x10,%esp
801042a1:	85 c0                	test   %eax,%eax
801042a3:	78 18                	js     801042bd <create+0x149>
801042a5:	83 ec 04             	sub    $0x4,%esp
801042a8:	ff 76 04             	pushl  0x4(%esi)
801042ab:	68 fd 6c 10 80       	push   $0x80106cfd
801042b0:	53                   	push   %ebx
801042b1:	e8 86 d8 ff ff       	call   80101b3c <dirlink>
801042b6:	83 c4 10             	add    $0x10,%esp
801042b9:	85 c0                	test   %eax,%eax
801042bb:	79 87                	jns    80104244 <create+0xd0>
      panic("create dots");
801042bd:	83 ec 0c             	sub    $0xc,%esp
801042c0:	68 00 6d 10 80       	push   $0x80106d00
801042c5:	e8 7e c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801042ca:	83 ec 0c             	sub    $0xc,%esp
801042cd:	68 0c 6d 10 80       	push   $0x80106d0c
801042d2:	e8 71 c0 ff ff       	call   80100348 <panic>
    return 0;
801042d7:	89 c3                	mov    %eax,%ebx
801042d9:	e9 04 ff ff ff       	jmp    801041e2 <create+0x6e>

801042de <sys_dup>:
{
801042de:	55                   	push   %ebp
801042df:	89 e5                	mov    %esp,%ebp
801042e1:	53                   	push   %ebx
801042e2:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042e5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042e8:	ba 00 00 00 00       	mov    $0x0,%edx
801042ed:	b8 00 00 00 00       	mov    $0x0,%eax
801042f2:	e8 88 fd ff ff       	call   8010407f <argfd>
801042f7:	85 c0                	test   %eax,%eax
801042f9:	78 23                	js     8010431e <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	e8 e3 fd ff ff       	call   801040e6 <fdalloc>
80104303:	89 c3                	mov    %eax,%ebx
80104305:	85 c0                	test   %eax,%eax
80104307:	78 1c                	js     80104325 <sys_dup+0x47>
  filedup(f);
80104309:	83 ec 0c             	sub    $0xc,%esp
8010430c:	ff 75 f4             	pushl  -0xc(%ebp)
8010430f:	e8 86 c9 ff ff       	call   80100c9a <filedup>
  return fd;
80104314:	83 c4 10             	add    $0x10,%esp
}
80104317:	89 d8                	mov    %ebx,%eax
80104319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010431c:	c9                   	leave  
8010431d:	c3                   	ret    
    return -1;
8010431e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104323:	eb f2                	jmp    80104317 <sys_dup+0x39>
    return -1;
80104325:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010432a:	eb eb                	jmp    80104317 <sys_dup+0x39>

8010432c <sys_read>:
{
8010432c:	55                   	push   %ebp
8010432d:	89 e5                	mov    %esp,%ebp
8010432f:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104332:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104335:	ba 00 00 00 00       	mov    $0x0,%edx
8010433a:	b8 00 00 00 00       	mov    $0x0,%eax
8010433f:	e8 3b fd ff ff       	call   8010407f <argfd>
80104344:	85 c0                	test   %eax,%eax
80104346:	78 43                	js     8010438b <sys_read+0x5f>
80104348:	83 ec 08             	sub    $0x8,%esp
8010434b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010434e:	50                   	push   %eax
8010434f:	6a 02                	push   $0x2
80104351:	e8 11 fc ff ff       	call   80103f67 <argint>
80104356:	83 c4 10             	add    $0x10,%esp
80104359:	85 c0                	test   %eax,%eax
8010435b:	78 35                	js     80104392 <sys_read+0x66>
8010435d:	83 ec 04             	sub    $0x4,%esp
80104360:	ff 75 f0             	pushl  -0x10(%ebp)
80104363:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104366:	50                   	push   %eax
80104367:	6a 01                	push   $0x1
80104369:	e8 21 fc ff ff       	call   80103f8f <argptr>
8010436e:	83 c4 10             	add    $0x10,%esp
80104371:	85 c0                	test   %eax,%eax
80104373:	78 24                	js     80104399 <sys_read+0x6d>
  return fileread(f, p, n);
80104375:	83 ec 04             	sub    $0x4,%esp
80104378:	ff 75 f0             	pushl  -0x10(%ebp)
8010437b:	ff 75 ec             	pushl  -0x14(%ebp)
8010437e:	ff 75 f4             	pushl  -0xc(%ebp)
80104381:	e8 5d ca ff ff       	call   80100de3 <fileread>
80104386:	83 c4 10             	add    $0x10,%esp
}
80104389:	c9                   	leave  
8010438a:	c3                   	ret    
    return -1;
8010438b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104390:	eb f7                	jmp    80104389 <sys_read+0x5d>
80104392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104397:	eb f0                	jmp    80104389 <sys_read+0x5d>
80104399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010439e:	eb e9                	jmp    80104389 <sys_read+0x5d>

801043a0 <sys_write>:
{
801043a0:	55                   	push   %ebp
801043a1:	89 e5                	mov    %esp,%ebp
801043a3:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043a6:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043a9:	ba 00 00 00 00       	mov    $0x0,%edx
801043ae:	b8 00 00 00 00       	mov    $0x0,%eax
801043b3:	e8 c7 fc ff ff       	call   8010407f <argfd>
801043b8:	85 c0                	test   %eax,%eax
801043ba:	78 43                	js     801043ff <sys_write+0x5f>
801043bc:	83 ec 08             	sub    $0x8,%esp
801043bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043c2:	50                   	push   %eax
801043c3:	6a 02                	push   $0x2
801043c5:	e8 9d fb ff ff       	call   80103f67 <argint>
801043ca:	83 c4 10             	add    $0x10,%esp
801043cd:	85 c0                	test   %eax,%eax
801043cf:	78 35                	js     80104406 <sys_write+0x66>
801043d1:	83 ec 04             	sub    $0x4,%esp
801043d4:	ff 75 f0             	pushl  -0x10(%ebp)
801043d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043da:	50                   	push   %eax
801043db:	6a 01                	push   $0x1
801043dd:	e8 ad fb ff ff       	call   80103f8f <argptr>
801043e2:	83 c4 10             	add    $0x10,%esp
801043e5:	85 c0                	test   %eax,%eax
801043e7:	78 24                	js     8010440d <sys_write+0x6d>
  return filewrite(f, p, n);
801043e9:	83 ec 04             	sub    $0x4,%esp
801043ec:	ff 75 f0             	pushl  -0x10(%ebp)
801043ef:	ff 75 ec             	pushl  -0x14(%ebp)
801043f2:	ff 75 f4             	pushl  -0xc(%ebp)
801043f5:	e8 6e ca ff ff       	call   80100e68 <filewrite>
801043fa:	83 c4 10             	add    $0x10,%esp
}
801043fd:	c9                   	leave  
801043fe:	c3                   	ret    
    return -1;
801043ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104404:	eb f7                	jmp    801043fd <sys_write+0x5d>
80104406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010440b:	eb f0                	jmp    801043fd <sys_write+0x5d>
8010440d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104412:	eb e9                	jmp    801043fd <sys_write+0x5d>

80104414 <sys_close>:
{
80104414:	55                   	push   %ebp
80104415:	89 e5                	mov    %esp,%ebp
80104417:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
8010441a:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010441d:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104420:	b8 00 00 00 00       	mov    $0x0,%eax
80104425:	e8 55 fc ff ff       	call   8010407f <argfd>
8010442a:	85 c0                	test   %eax,%eax
8010442c:	78 25                	js     80104453 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010442e:	e8 9b ee ff ff       	call   801032ce <myproc>
80104433:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104436:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010443d:	00 
  fileclose(f);
8010443e:	83 ec 0c             	sub    $0xc,%esp
80104441:	ff 75 f0             	pushl  -0x10(%ebp)
80104444:	e8 96 c8 ff ff       	call   80100cdf <fileclose>
  return 0;
80104449:	83 c4 10             	add    $0x10,%esp
8010444c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104451:	c9                   	leave  
80104452:	c3                   	ret    
    return -1;
80104453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104458:	eb f7                	jmp    80104451 <sys_close+0x3d>

8010445a <sys_fstat>:
{
8010445a:	55                   	push   %ebp
8010445b:	89 e5                	mov    %esp,%ebp
8010445d:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104460:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104463:	ba 00 00 00 00       	mov    $0x0,%edx
80104468:	b8 00 00 00 00       	mov    $0x0,%eax
8010446d:	e8 0d fc ff ff       	call   8010407f <argfd>
80104472:	85 c0                	test   %eax,%eax
80104474:	78 2a                	js     801044a0 <sys_fstat+0x46>
80104476:	83 ec 04             	sub    $0x4,%esp
80104479:	6a 14                	push   $0x14
8010447b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010447e:	50                   	push   %eax
8010447f:	6a 01                	push   $0x1
80104481:	e8 09 fb ff ff       	call   80103f8f <argptr>
80104486:	83 c4 10             	add    $0x10,%esp
80104489:	85 c0                	test   %eax,%eax
8010448b:	78 1a                	js     801044a7 <sys_fstat+0x4d>
  return filestat(f, st);
8010448d:	83 ec 08             	sub    $0x8,%esp
80104490:	ff 75 f0             	pushl  -0x10(%ebp)
80104493:	ff 75 f4             	pushl  -0xc(%ebp)
80104496:	e8 01 c9 ff ff       	call   80100d9c <filestat>
8010449b:	83 c4 10             	add    $0x10,%esp
}
8010449e:	c9                   	leave  
8010449f:	c3                   	ret    
    return -1;
801044a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044a5:	eb f7                	jmp    8010449e <sys_fstat+0x44>
801044a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ac:	eb f0                	jmp    8010449e <sys_fstat+0x44>

801044ae <sys_link>:
{
801044ae:	55                   	push   %ebp
801044af:	89 e5                	mov    %esp,%ebp
801044b1:	56                   	push   %esi
801044b2:	53                   	push   %ebx
801044b3:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801044b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044b9:	50                   	push   %eax
801044ba:	6a 00                	push   $0x0
801044bc:	e8 36 fb ff ff       	call   80103ff7 <argstr>
801044c1:	83 c4 10             	add    $0x10,%esp
801044c4:	85 c0                	test   %eax,%eax
801044c6:	0f 88 32 01 00 00    	js     801045fe <sys_link+0x150>
801044cc:	83 ec 08             	sub    $0x8,%esp
801044cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801044d2:	50                   	push   %eax
801044d3:	6a 01                	push   $0x1
801044d5:	e8 1d fb ff ff       	call   80103ff7 <argstr>
801044da:	83 c4 10             	add    $0x10,%esp
801044dd:	85 c0                	test   %eax,%eax
801044df:	0f 88 20 01 00 00    	js     80104605 <sys_link+0x157>
  begin_op();
801044e5:	e8 89 e3 ff ff       	call   80102873 <begin_op>
  if((ip = namei(old)) == 0){
801044ea:	83 ec 0c             	sub    $0xc,%esp
801044ed:	ff 75 e0             	pushl  -0x20(%ebp)
801044f0:	e8 f8 d6 ff ff       	call   80101bed <namei>
801044f5:	89 c3                	mov    %eax,%ebx
801044f7:	83 c4 10             	add    $0x10,%esp
801044fa:	85 c0                	test   %eax,%eax
801044fc:	0f 84 99 00 00 00    	je     8010459b <sys_link+0xed>
  ilock(ip);
80104502:	83 ec 0c             	sub    $0xc,%esp
80104505:	50                   	push   %eax
80104506:	e8 82 d0 ff ff       	call   8010158d <ilock>
  if(ip->type == T_DIR){
8010450b:	83 c4 10             	add    $0x10,%esp
8010450e:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104513:	0f 84 8e 00 00 00    	je     801045a7 <sys_link+0xf9>
  ip->nlink++;
80104519:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010451d:	83 c0 01             	add    $0x1,%eax
80104520:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104524:	83 ec 0c             	sub    $0xc,%esp
80104527:	53                   	push   %ebx
80104528:	e8 ff ce ff ff       	call   8010142c <iupdate>
  iunlock(ip);
8010452d:	89 1c 24             	mov    %ebx,(%esp)
80104530:	e8 1a d1 ff ff       	call   8010164f <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104535:	83 c4 08             	add    $0x8,%esp
80104538:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010453b:	50                   	push   %eax
8010453c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010453f:	e8 c1 d6 ff ff       	call   80101c05 <nameiparent>
80104544:	89 c6                	mov    %eax,%esi
80104546:	83 c4 10             	add    $0x10,%esp
80104549:	85 c0                	test   %eax,%eax
8010454b:	74 7e                	je     801045cb <sys_link+0x11d>
  ilock(dp);
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	50                   	push   %eax
80104551:	e8 37 d0 ff ff       	call   8010158d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104556:	83 c4 10             	add    $0x10,%esp
80104559:	8b 03                	mov    (%ebx),%eax
8010455b:	39 06                	cmp    %eax,(%esi)
8010455d:	75 60                	jne    801045bf <sys_link+0x111>
8010455f:	83 ec 04             	sub    $0x4,%esp
80104562:	ff 73 04             	pushl  0x4(%ebx)
80104565:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104568:	50                   	push   %eax
80104569:	56                   	push   %esi
8010456a:	e8 cd d5 ff ff       	call   80101b3c <dirlink>
8010456f:	83 c4 10             	add    $0x10,%esp
80104572:	85 c0                	test   %eax,%eax
80104574:	78 49                	js     801045bf <sys_link+0x111>
  iunlockput(dp);
80104576:	83 ec 0c             	sub    $0xc,%esp
80104579:	56                   	push   %esi
8010457a:	e8 b5 d1 ff ff       	call   80101734 <iunlockput>
  iput(ip);
8010457f:	89 1c 24             	mov    %ebx,(%esp)
80104582:	e8 0d d1 ff ff       	call   80101694 <iput>
  end_op();
80104587:	e8 61 e3 ff ff       	call   801028ed <end_op>
  return 0;
8010458c:	83 c4 10             	add    $0x10,%esp
8010458f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104594:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104597:	5b                   	pop    %ebx
80104598:	5e                   	pop    %esi
80104599:	5d                   	pop    %ebp
8010459a:	c3                   	ret    
    end_op();
8010459b:	e8 4d e3 ff ff       	call   801028ed <end_op>
    return -1;
801045a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a5:	eb ed                	jmp    80104594 <sys_link+0xe6>
    iunlockput(ip);
801045a7:	83 ec 0c             	sub    $0xc,%esp
801045aa:	53                   	push   %ebx
801045ab:	e8 84 d1 ff ff       	call   80101734 <iunlockput>
    end_op();
801045b0:	e8 38 e3 ff ff       	call   801028ed <end_op>
    return -1;
801045b5:	83 c4 10             	add    $0x10,%esp
801045b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045bd:	eb d5                	jmp    80104594 <sys_link+0xe6>
    iunlockput(dp);
801045bf:	83 ec 0c             	sub    $0xc,%esp
801045c2:	56                   	push   %esi
801045c3:	e8 6c d1 ff ff       	call   80101734 <iunlockput>
    goto bad;
801045c8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801045cb:	83 ec 0c             	sub    $0xc,%esp
801045ce:	53                   	push   %ebx
801045cf:	e8 b9 cf ff ff       	call   8010158d <ilock>
  ip->nlink--;
801045d4:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045d8:	83 e8 01             	sub    $0x1,%eax
801045db:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045df:	89 1c 24             	mov    %ebx,(%esp)
801045e2:	e8 45 ce ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801045e7:	89 1c 24             	mov    %ebx,(%esp)
801045ea:	e8 45 d1 ff ff       	call   80101734 <iunlockput>
  end_op();
801045ef:	e8 f9 e2 ff ff       	call   801028ed <end_op>
  return -1;
801045f4:	83 c4 10             	add    $0x10,%esp
801045f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fc:	eb 96                	jmp    80104594 <sys_link+0xe6>
    return -1;
801045fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104603:	eb 8f                	jmp    80104594 <sys_link+0xe6>
80104605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460a:	eb 88                	jmp    80104594 <sys_link+0xe6>

8010460c <sys_unlink>:
{
8010460c:	55                   	push   %ebp
8010460d:	89 e5                	mov    %esp,%ebp
8010460f:	57                   	push   %edi
80104610:	56                   	push   %esi
80104611:	53                   	push   %ebx
80104612:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104615:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104618:	50                   	push   %eax
80104619:	6a 00                	push   $0x0
8010461b:	e8 d7 f9 ff ff       	call   80103ff7 <argstr>
80104620:	83 c4 10             	add    $0x10,%esp
80104623:	85 c0                	test   %eax,%eax
80104625:	0f 88 83 01 00 00    	js     801047ae <sys_unlink+0x1a2>
  begin_op();
8010462b:	e8 43 e2 ff ff       	call   80102873 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104630:	83 ec 08             	sub    $0x8,%esp
80104633:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104636:	50                   	push   %eax
80104637:	ff 75 c4             	pushl  -0x3c(%ebp)
8010463a:	e8 c6 d5 ff ff       	call   80101c05 <nameiparent>
8010463f:	89 c6                	mov    %eax,%esi
80104641:	83 c4 10             	add    $0x10,%esp
80104644:	85 c0                	test   %eax,%eax
80104646:	0f 84 ed 00 00 00    	je     80104739 <sys_unlink+0x12d>
  ilock(dp);
8010464c:	83 ec 0c             	sub    $0xc,%esp
8010464f:	50                   	push   %eax
80104650:	e8 38 cf ff ff       	call   8010158d <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104655:	83 c4 08             	add    $0x8,%esp
80104658:	68 fe 6c 10 80       	push   $0x80106cfe
8010465d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104660:	50                   	push   %eax
80104661:	e8 41 d3 ff ff       	call   801019a7 <namecmp>
80104666:	83 c4 10             	add    $0x10,%esp
80104669:	85 c0                	test   %eax,%eax
8010466b:	0f 84 fc 00 00 00    	je     8010476d <sys_unlink+0x161>
80104671:	83 ec 08             	sub    $0x8,%esp
80104674:	68 fd 6c 10 80       	push   $0x80106cfd
80104679:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010467c:	50                   	push   %eax
8010467d:	e8 25 d3 ff ff       	call   801019a7 <namecmp>
80104682:	83 c4 10             	add    $0x10,%esp
80104685:	85 c0                	test   %eax,%eax
80104687:	0f 84 e0 00 00 00    	je     8010476d <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010468d:	83 ec 04             	sub    $0x4,%esp
80104690:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104693:	50                   	push   %eax
80104694:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104697:	50                   	push   %eax
80104698:	56                   	push   %esi
80104699:	e8 1e d3 ff ff       	call   801019bc <dirlookup>
8010469e:	89 c3                	mov    %eax,%ebx
801046a0:	83 c4 10             	add    $0x10,%esp
801046a3:	85 c0                	test   %eax,%eax
801046a5:	0f 84 c2 00 00 00    	je     8010476d <sys_unlink+0x161>
  ilock(ip);
801046ab:	83 ec 0c             	sub    $0xc,%esp
801046ae:	50                   	push   %eax
801046af:	e8 d9 ce ff ff       	call   8010158d <ilock>
  if(ip->nlink < 1)
801046b4:	83 c4 10             	add    $0x10,%esp
801046b7:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801046bc:	0f 8e 83 00 00 00    	jle    80104745 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801046c2:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046c7:	0f 84 85 00 00 00    	je     80104752 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801046cd:	83 ec 04             	sub    $0x4,%esp
801046d0:	6a 10                	push   $0x10
801046d2:	6a 00                	push   $0x0
801046d4:	8d 7d d8             	lea    -0x28(%ebp),%edi
801046d7:	57                   	push   %edi
801046d8:	e8 3f f6 ff ff       	call   80103d1c <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046dd:	6a 10                	push   $0x10
801046df:	ff 75 c0             	pushl  -0x40(%ebp)
801046e2:	57                   	push   %edi
801046e3:	56                   	push   %esi
801046e4:	e8 93 d1 ff ff       	call   8010187c <writei>
801046e9:	83 c4 20             	add    $0x20,%esp
801046ec:	83 f8 10             	cmp    $0x10,%eax
801046ef:	0f 85 90 00 00 00    	jne    80104785 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801046f5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046fa:	0f 84 92 00 00 00    	je     80104792 <sys_unlink+0x186>
  iunlockput(dp);
80104700:	83 ec 0c             	sub    $0xc,%esp
80104703:	56                   	push   %esi
80104704:	e8 2b d0 ff ff       	call   80101734 <iunlockput>
  ip->nlink--;
80104709:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010470d:	83 e8 01             	sub    $0x1,%eax
80104710:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104714:	89 1c 24             	mov    %ebx,(%esp)
80104717:	e8 10 cd ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
8010471c:	89 1c 24             	mov    %ebx,(%esp)
8010471f:	e8 10 d0 ff ff       	call   80101734 <iunlockput>
  end_op();
80104724:	e8 c4 e1 ff ff       	call   801028ed <end_op>
  return 0;
80104729:	83 c4 10             	add    $0x10,%esp
8010472c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104731:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104734:	5b                   	pop    %ebx
80104735:	5e                   	pop    %esi
80104736:	5f                   	pop    %edi
80104737:	5d                   	pop    %ebp
80104738:	c3                   	ret    
    end_op();
80104739:	e8 af e1 ff ff       	call   801028ed <end_op>
    return -1;
8010473e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104743:	eb ec                	jmp    80104731 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104745:	83 ec 0c             	sub    $0xc,%esp
80104748:	68 1c 6d 10 80       	push   $0x80106d1c
8010474d:	e8 f6 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104752:	89 d8                	mov    %ebx,%eax
80104754:	e8 c4 f9 ff ff       	call   8010411d <isdirempty>
80104759:	85 c0                	test   %eax,%eax
8010475b:	0f 85 6c ff ff ff    	jne    801046cd <sys_unlink+0xc1>
    iunlockput(ip);
80104761:	83 ec 0c             	sub    $0xc,%esp
80104764:	53                   	push   %ebx
80104765:	e8 ca cf ff ff       	call   80101734 <iunlockput>
    goto bad;
8010476a:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010476d:	83 ec 0c             	sub    $0xc,%esp
80104770:	56                   	push   %esi
80104771:	e8 be cf ff ff       	call   80101734 <iunlockput>
  end_op();
80104776:	e8 72 e1 ff ff       	call   801028ed <end_op>
  return -1;
8010477b:	83 c4 10             	add    $0x10,%esp
8010477e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104783:	eb ac                	jmp    80104731 <sys_unlink+0x125>
    panic("unlink: writei");
80104785:	83 ec 0c             	sub    $0xc,%esp
80104788:	68 2e 6d 10 80       	push   $0x80106d2e
8010478d:	e8 b6 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
80104792:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104796:	83 e8 01             	sub    $0x1,%eax
80104799:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010479d:	83 ec 0c             	sub    $0xc,%esp
801047a0:	56                   	push   %esi
801047a1:	e8 86 cc ff ff       	call   8010142c <iupdate>
801047a6:	83 c4 10             	add    $0x10,%esp
801047a9:	e9 52 ff ff ff       	jmp    80104700 <sys_unlink+0xf4>
    return -1;
801047ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b3:	e9 79 ff ff ff       	jmp    80104731 <sys_unlink+0x125>

801047b8 <sys_open>:

int
sys_open(void)
{
801047b8:	55                   	push   %ebp
801047b9:	89 e5                	mov    %esp,%ebp
801047bb:	57                   	push   %edi
801047bc:	56                   	push   %esi
801047bd:	53                   	push   %ebx
801047be:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801047c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047c4:	50                   	push   %eax
801047c5:	6a 00                	push   $0x0
801047c7:	e8 2b f8 ff ff       	call   80103ff7 <argstr>
801047cc:	83 c4 10             	add    $0x10,%esp
801047cf:	85 c0                	test   %eax,%eax
801047d1:	0f 88 30 01 00 00    	js     80104907 <sys_open+0x14f>
801047d7:	83 ec 08             	sub    $0x8,%esp
801047da:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047dd:	50                   	push   %eax
801047de:	6a 01                	push   $0x1
801047e0:	e8 82 f7 ff ff       	call   80103f67 <argint>
801047e5:	83 c4 10             	add    $0x10,%esp
801047e8:	85 c0                	test   %eax,%eax
801047ea:	0f 88 21 01 00 00    	js     80104911 <sys_open+0x159>
    return -1;

  begin_op();
801047f0:	e8 7e e0 ff ff       	call   80102873 <begin_op>

  if(omode & O_CREATE){
801047f5:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801047f9:	0f 84 84 00 00 00    	je     80104883 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801047ff:	83 ec 0c             	sub    $0xc,%esp
80104802:	6a 00                	push   $0x0
80104804:	b9 00 00 00 00       	mov    $0x0,%ecx
80104809:	ba 02 00 00 00       	mov    $0x2,%edx
8010480e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104811:	e8 5e f9 ff ff       	call   80104174 <create>
80104816:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104818:	83 c4 10             	add    $0x10,%esp
8010481b:	85 c0                	test   %eax,%eax
8010481d:	74 58                	je     80104877 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010481f:	e8 15 c4 ff ff       	call   80100c39 <filealloc>
80104824:	89 c3                	mov    %eax,%ebx
80104826:	85 c0                	test   %eax,%eax
80104828:	0f 84 ae 00 00 00    	je     801048dc <sys_open+0x124>
8010482e:	e8 b3 f8 ff ff       	call   801040e6 <fdalloc>
80104833:	89 c7                	mov    %eax,%edi
80104835:	85 c0                	test   %eax,%eax
80104837:	0f 88 9f 00 00 00    	js     801048dc <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010483d:	83 ec 0c             	sub    $0xc,%esp
80104840:	56                   	push   %esi
80104841:	e8 09 ce ff ff       	call   8010164f <iunlock>
  end_op();
80104846:	e8 a2 e0 ff ff       	call   801028ed <end_op>

  f->type = FD_INODE;
8010484b:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104851:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104854:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010485b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010485e:	83 c4 10             	add    $0x10,%esp
80104861:	a8 01                	test   $0x1,%al
80104863:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104867:	a8 03                	test   $0x3,%al
80104869:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010486d:	89 f8                	mov    %edi,%eax
8010486f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104872:	5b                   	pop    %ebx
80104873:	5e                   	pop    %esi
80104874:	5f                   	pop    %edi
80104875:	5d                   	pop    %ebp
80104876:	c3                   	ret    
      end_op();
80104877:	e8 71 e0 ff ff       	call   801028ed <end_op>
      return -1;
8010487c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104881:	eb ea                	jmp    8010486d <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104883:	83 ec 0c             	sub    $0xc,%esp
80104886:	ff 75 e4             	pushl  -0x1c(%ebp)
80104889:	e8 5f d3 ff ff       	call   80101bed <namei>
8010488e:	89 c6                	mov    %eax,%esi
80104890:	83 c4 10             	add    $0x10,%esp
80104893:	85 c0                	test   %eax,%eax
80104895:	74 39                	je     801048d0 <sys_open+0x118>
    ilock(ip);
80104897:	83 ec 0c             	sub    $0xc,%esp
8010489a:	50                   	push   %eax
8010489b:	e8 ed cc ff ff       	call   8010158d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801048a0:	83 c4 10             	add    $0x10,%esp
801048a3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801048a8:	0f 85 71 ff ff ff    	jne    8010481f <sys_open+0x67>
801048ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048b2:	0f 84 67 ff ff ff    	je     8010481f <sys_open+0x67>
      iunlockput(ip);
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	56                   	push   %esi
801048bc:	e8 73 ce ff ff       	call   80101734 <iunlockput>
      end_op();
801048c1:	e8 27 e0 ff ff       	call   801028ed <end_op>
      return -1;
801048c6:	83 c4 10             	add    $0x10,%esp
801048c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048ce:	eb 9d                	jmp    8010486d <sys_open+0xb5>
      end_op();
801048d0:	e8 18 e0 ff ff       	call   801028ed <end_op>
      return -1;
801048d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048da:	eb 91                	jmp    8010486d <sys_open+0xb5>
    if(f)
801048dc:	85 db                	test   %ebx,%ebx
801048de:	74 0c                	je     801048ec <sys_open+0x134>
      fileclose(f);
801048e0:	83 ec 0c             	sub    $0xc,%esp
801048e3:	53                   	push   %ebx
801048e4:	e8 f6 c3 ff ff       	call   80100cdf <fileclose>
801048e9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801048ec:	83 ec 0c             	sub    $0xc,%esp
801048ef:	56                   	push   %esi
801048f0:	e8 3f ce ff ff       	call   80101734 <iunlockput>
    end_op();
801048f5:	e8 f3 df ff ff       	call   801028ed <end_op>
    return -1;
801048fa:	83 c4 10             	add    $0x10,%esp
801048fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104902:	e9 66 ff ff ff       	jmp    8010486d <sys_open+0xb5>
    return -1;
80104907:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010490c:	e9 5c ff ff ff       	jmp    8010486d <sys_open+0xb5>
80104911:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104916:	e9 52 ff ff ff       	jmp    8010486d <sys_open+0xb5>

8010491b <sys_mkdir>:

int
sys_mkdir(void)
{
8010491b:	55                   	push   %ebp
8010491c:	89 e5                	mov    %esp,%ebp
8010491e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104921:	e8 4d df ff ff       	call   80102873 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104926:	83 ec 08             	sub    $0x8,%esp
80104929:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010492c:	50                   	push   %eax
8010492d:	6a 00                	push   $0x0
8010492f:	e8 c3 f6 ff ff       	call   80103ff7 <argstr>
80104934:	83 c4 10             	add    $0x10,%esp
80104937:	85 c0                	test   %eax,%eax
80104939:	78 36                	js     80104971 <sys_mkdir+0x56>
8010493b:	83 ec 0c             	sub    $0xc,%esp
8010493e:	6a 00                	push   $0x0
80104940:	b9 00 00 00 00       	mov    $0x0,%ecx
80104945:	ba 01 00 00 00       	mov    $0x1,%edx
8010494a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494d:	e8 22 f8 ff ff       	call   80104174 <create>
80104952:	83 c4 10             	add    $0x10,%esp
80104955:	85 c0                	test   %eax,%eax
80104957:	74 18                	je     80104971 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104959:	83 ec 0c             	sub    $0xc,%esp
8010495c:	50                   	push   %eax
8010495d:	e8 d2 cd ff ff       	call   80101734 <iunlockput>
  end_op();
80104962:	e8 86 df ff ff       	call   801028ed <end_op>
  return 0;
80104967:	83 c4 10             	add    $0x10,%esp
8010496a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010496f:	c9                   	leave  
80104970:	c3                   	ret    
    end_op();
80104971:	e8 77 df ff ff       	call   801028ed <end_op>
    return -1;
80104976:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497b:	eb f2                	jmp    8010496f <sys_mkdir+0x54>

8010497d <sys_mknod>:

int
sys_mknod(void)
{
8010497d:	55                   	push   %ebp
8010497e:	89 e5                	mov    %esp,%ebp
80104980:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104983:	e8 eb de ff ff       	call   80102873 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104988:	83 ec 08             	sub    $0x8,%esp
8010498b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010498e:	50                   	push   %eax
8010498f:	6a 00                	push   $0x0
80104991:	e8 61 f6 ff ff       	call   80103ff7 <argstr>
80104996:	83 c4 10             	add    $0x10,%esp
80104999:	85 c0                	test   %eax,%eax
8010499b:	78 62                	js     801049ff <sys_mknod+0x82>
     argint(1, &major) < 0 ||
8010499d:	83 ec 08             	sub    $0x8,%esp
801049a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801049a3:	50                   	push   %eax
801049a4:	6a 01                	push   $0x1
801049a6:	e8 bc f5 ff ff       	call   80103f67 <argint>
  if((argstr(0, &path)) < 0 ||
801049ab:	83 c4 10             	add    $0x10,%esp
801049ae:	85 c0                	test   %eax,%eax
801049b0:	78 4d                	js     801049ff <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
801049b2:	83 ec 08             	sub    $0x8,%esp
801049b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801049b8:	50                   	push   %eax
801049b9:	6a 02                	push   $0x2
801049bb:	e8 a7 f5 ff ff       	call   80103f67 <argint>
     argint(1, &major) < 0 ||
801049c0:	83 c4 10             	add    $0x10,%esp
801049c3:	85 c0                	test   %eax,%eax
801049c5:	78 38                	js     801049ff <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
801049c7:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801049cb:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801049cf:	83 ec 0c             	sub    $0xc,%esp
801049d2:	50                   	push   %eax
801049d3:	ba 03 00 00 00       	mov    $0x3,%edx
801049d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049db:	e8 94 f7 ff ff       	call   80104174 <create>
801049e0:	83 c4 10             	add    $0x10,%esp
801049e3:	85 c0                	test   %eax,%eax
801049e5:	74 18                	je     801049ff <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049e7:	83 ec 0c             	sub    $0xc,%esp
801049ea:	50                   	push   %eax
801049eb:	e8 44 cd ff ff       	call   80101734 <iunlockput>
  end_op();
801049f0:	e8 f8 de ff ff       	call   801028ed <end_op>
  return 0;
801049f5:	83 c4 10             	add    $0x10,%esp
801049f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049fd:	c9                   	leave  
801049fe:	c3                   	ret    
    end_op();
801049ff:	e8 e9 de ff ff       	call   801028ed <end_op>
    return -1;
80104a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a09:	eb f2                	jmp    801049fd <sys_mknod+0x80>

80104a0b <sys_chdir>:

int
sys_chdir(void)
{
80104a0b:	55                   	push   %ebp
80104a0c:	89 e5                	mov    %esp,%ebp
80104a0e:	56                   	push   %esi
80104a0f:	53                   	push   %ebx
80104a10:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a13:	e8 b6 e8 ff ff       	call   801032ce <myproc>
80104a18:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104a1a:	e8 54 de ff ff       	call   80102873 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a1f:	83 ec 08             	sub    $0x8,%esp
80104a22:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a25:	50                   	push   %eax
80104a26:	6a 00                	push   $0x0
80104a28:	e8 ca f5 ff ff       	call   80103ff7 <argstr>
80104a2d:	83 c4 10             	add    $0x10,%esp
80104a30:	85 c0                	test   %eax,%eax
80104a32:	78 52                	js     80104a86 <sys_chdir+0x7b>
80104a34:	83 ec 0c             	sub    $0xc,%esp
80104a37:	ff 75 f4             	pushl  -0xc(%ebp)
80104a3a:	e8 ae d1 ff ff       	call   80101bed <namei>
80104a3f:	89 c3                	mov    %eax,%ebx
80104a41:	83 c4 10             	add    $0x10,%esp
80104a44:	85 c0                	test   %eax,%eax
80104a46:	74 3e                	je     80104a86 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104a48:	83 ec 0c             	sub    $0xc,%esp
80104a4b:	50                   	push   %eax
80104a4c:	e8 3c cb ff ff       	call   8010158d <ilock>
  if(ip->type != T_DIR){
80104a51:	83 c4 10             	add    $0x10,%esp
80104a54:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a59:	75 37                	jne    80104a92 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a5b:	83 ec 0c             	sub    $0xc,%esp
80104a5e:	53                   	push   %ebx
80104a5f:	e8 eb cb ff ff       	call   8010164f <iunlock>
  iput(curproc->cwd);
80104a64:	83 c4 04             	add    $0x4,%esp
80104a67:	ff 76 68             	pushl  0x68(%esi)
80104a6a:	e8 25 cc ff ff       	call   80101694 <iput>
  end_op();
80104a6f:	e8 79 de ff ff       	call   801028ed <end_op>
  curproc->cwd = ip;
80104a74:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a77:	83 c4 10             	add    $0x10,%esp
80104a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a82:	5b                   	pop    %ebx
80104a83:	5e                   	pop    %esi
80104a84:	5d                   	pop    %ebp
80104a85:	c3                   	ret    
    end_op();
80104a86:	e8 62 de ff ff       	call   801028ed <end_op>
    return -1;
80104a8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a90:	eb ed                	jmp    80104a7f <sys_chdir+0x74>
    iunlockput(ip);
80104a92:	83 ec 0c             	sub    $0xc,%esp
80104a95:	53                   	push   %ebx
80104a96:	e8 99 cc ff ff       	call   80101734 <iunlockput>
    end_op();
80104a9b:	e8 4d de ff ff       	call   801028ed <end_op>
    return -1;
80104aa0:	83 c4 10             	add    $0x10,%esp
80104aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa8:	eb d5                	jmp    80104a7f <sys_chdir+0x74>

80104aaa <sys_exec>:

int
sys_exec(void)
{
80104aaa:	55                   	push   %ebp
80104aab:	89 e5                	mov    %esp,%ebp
80104aad:	53                   	push   %ebx
80104aae:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ab7:	50                   	push   %eax
80104ab8:	6a 00                	push   $0x0
80104aba:	e8 38 f5 ff ff       	call   80103ff7 <argstr>
80104abf:	83 c4 10             	add    $0x10,%esp
80104ac2:	85 c0                	test   %eax,%eax
80104ac4:	0f 88 a8 00 00 00    	js     80104b72 <sys_exec+0xc8>
80104aca:	83 ec 08             	sub    $0x8,%esp
80104acd:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104ad3:	50                   	push   %eax
80104ad4:	6a 01                	push   $0x1
80104ad6:	e8 8c f4 ff ff       	call   80103f67 <argint>
80104adb:	83 c4 10             	add    $0x10,%esp
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	0f 88 93 00 00 00    	js     80104b79 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ae6:	83 ec 04             	sub    $0x4,%esp
80104ae9:	68 80 00 00 00       	push   $0x80
80104aee:	6a 00                	push   $0x0
80104af0:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104af6:	50                   	push   %eax
80104af7:	e8 20 f2 ff ff       	call   80103d1c <memset>
80104afc:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104aff:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104b04:	83 fb 1f             	cmp    $0x1f,%ebx
80104b07:	77 77                	ja     80104b80 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b09:	83 ec 08             	sub    $0x8,%esp
80104b0c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b12:	50                   	push   %eax
80104b13:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b19:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b1c:	50                   	push   %eax
80104b1d:	e8 c9 f3 ff ff       	call   80103eeb <fetchint>
80104b22:	83 c4 10             	add    $0x10,%esp
80104b25:	85 c0                	test   %eax,%eax
80104b27:	78 5e                	js     80104b87 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104b29:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b2f:	85 c0                	test   %eax,%eax
80104b31:	74 1d                	je     80104b50 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104b33:	83 ec 08             	sub    $0x8,%esp
80104b36:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b3d:	52                   	push   %edx
80104b3e:	50                   	push   %eax
80104b3f:	e8 e3 f3 ff ff       	call   80103f27 <fetchstr>
80104b44:	83 c4 10             	add    $0x10,%esp
80104b47:	85 c0                	test   %eax,%eax
80104b49:	78 46                	js     80104b91 <sys_exec+0xe7>
  for(i=0;; i++){
80104b4b:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104b4e:	eb b4                	jmp    80104b04 <sys_exec+0x5a>
      argv[i] = 0;
80104b50:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b57:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104b5b:	83 ec 08             	sub    $0x8,%esp
80104b5e:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b64:	50                   	push   %eax
80104b65:	ff 75 f4             	pushl  -0xc(%ebp)
80104b68:	e8 65 bd ff ff       	call   801008d2 <exec>
80104b6d:	83 c4 10             	add    $0x10,%esp
80104b70:	eb 1a                	jmp    80104b8c <sys_exec+0xe2>
    return -1;
80104b72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b77:	eb 13                	jmp    80104b8c <sys_exec+0xe2>
80104b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b7e:	eb 0c                	jmp    80104b8c <sys_exec+0xe2>
      return -1;
80104b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b85:	eb 05                	jmp    80104b8c <sys_exec+0xe2>
      return -1;
80104b87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b8f:	c9                   	leave  
80104b90:	c3                   	ret    
      return -1;
80104b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b96:	eb f4                	jmp    80104b8c <sys_exec+0xe2>

80104b98 <sys_pipe>:

int
sys_pipe(void)
{
80104b98:	55                   	push   %ebp
80104b99:	89 e5                	mov    %esp,%ebp
80104b9b:	53                   	push   %ebx
80104b9c:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b9f:	6a 08                	push   $0x8
80104ba1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ba4:	50                   	push   %eax
80104ba5:	6a 00                	push   $0x0
80104ba7:	e8 e3 f3 ff ff       	call   80103f8f <argptr>
80104bac:	83 c4 10             	add    $0x10,%esp
80104baf:	85 c0                	test   %eax,%eax
80104bb1:	78 77                	js     80104c2a <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104bb3:	83 ec 08             	sub    $0x8,%esp
80104bb6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104bb9:	50                   	push   %eax
80104bba:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bbd:	50                   	push   %eax
80104bbe:	e8 3c e2 ff ff       	call   80102dff <pipealloc>
80104bc3:	83 c4 10             	add    $0x10,%esp
80104bc6:	85 c0                	test   %eax,%eax
80104bc8:	78 67                	js     80104c31 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bcd:	e8 14 f5 ff ff       	call   801040e6 <fdalloc>
80104bd2:	89 c3                	mov    %eax,%ebx
80104bd4:	85 c0                	test   %eax,%eax
80104bd6:	78 21                	js     80104bf9 <sys_pipe+0x61>
80104bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bdb:	e8 06 f5 ff ff       	call   801040e6 <fdalloc>
80104be0:	85 c0                	test   %eax,%eax
80104be2:	78 15                	js     80104bf9 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104be7:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104be9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bec:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104bef:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bf7:	c9                   	leave  
80104bf8:	c3                   	ret    
    if(fd0 >= 0)
80104bf9:	85 db                	test   %ebx,%ebx
80104bfb:	78 0d                	js     80104c0a <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104bfd:	e8 cc e6 ff ff       	call   801032ce <myproc>
80104c02:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104c09:	00 
    fileclose(rf);
80104c0a:	83 ec 0c             	sub    $0xc,%esp
80104c0d:	ff 75 f0             	pushl  -0x10(%ebp)
80104c10:	e8 ca c0 ff ff       	call   80100cdf <fileclose>
    fileclose(wf);
80104c15:	83 c4 04             	add    $0x4,%esp
80104c18:	ff 75 ec             	pushl  -0x14(%ebp)
80104c1b:	e8 bf c0 ff ff       	call   80100cdf <fileclose>
    return -1;
80104c20:	83 c4 10             	add    $0x10,%esp
80104c23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c28:	eb ca                	jmp    80104bf4 <sys_pipe+0x5c>
    return -1;
80104c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c2f:	eb c3                	jmp    80104bf4 <sys_pipe+0x5c>
    return -1;
80104c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c36:	eb bc                	jmp    80104bf4 <sys_pipe+0x5c>

80104c38 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104c38:	55                   	push   %ebp
80104c39:	89 e5                	mov    %esp,%ebp
80104c3b:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c3e:	e8 03 e8 ff ff       	call   80103446 <fork>
}
80104c43:	c9                   	leave  
80104c44:	c3                   	ret    

80104c45 <sys_exit>:

int
sys_exit(void)
{
80104c45:	55                   	push   %ebp
80104c46:	89 e5                	mov    %esp,%ebp
80104c48:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c4b:	e8 2d ea ff ff       	call   8010367d <exit>
  return 0;  // not reached
}
80104c50:	b8 00 00 00 00       	mov    $0x0,%eax
80104c55:	c9                   	leave  
80104c56:	c3                   	ret    

80104c57 <sys_wait>:

int
sys_wait(void)
{
80104c57:	55                   	push   %ebp
80104c58:	89 e5                	mov    %esp,%ebp
80104c5a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c5d:	e8 a4 eb ff ff       	call   80103806 <wait>
}
80104c62:	c9                   	leave  
80104c63:	c3                   	ret    

80104c64 <sys_kill>:

int
sys_kill(void)
{
80104c64:	55                   	push   %ebp
80104c65:	89 e5                	mov    %esp,%ebp
80104c67:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c6d:	50                   	push   %eax
80104c6e:	6a 00                	push   $0x0
80104c70:	e8 f2 f2 ff ff       	call   80103f67 <argint>
80104c75:	83 c4 10             	add    $0x10,%esp
80104c78:	85 c0                	test   %eax,%eax
80104c7a:	78 10                	js     80104c8c <sys_kill+0x28>
    return -1;
  return kill(pid);
80104c7c:	83 ec 0c             	sub    $0xc,%esp
80104c7f:	ff 75 f4             	pushl  -0xc(%ebp)
80104c82:	e8 7c ec ff ff       	call   80103903 <kill>
80104c87:	83 c4 10             	add    $0x10,%esp
}
80104c8a:	c9                   	leave  
80104c8b:	c3                   	ret    
    return -1;
80104c8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c91:	eb f7                	jmp    80104c8a <sys_kill+0x26>

80104c93 <sys_getpid>:

int
sys_getpid(void)
{
80104c93:	55                   	push   %ebp
80104c94:	89 e5                	mov    %esp,%ebp
80104c96:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c99:	e8 30 e6 ff ff       	call   801032ce <myproc>
80104c9e:	8b 40 10             	mov    0x10(%eax),%eax
}
80104ca1:	c9                   	leave  
80104ca2:	c3                   	ret    

80104ca3 <sys_sbrk>:

int
sys_sbrk(void)
{
80104ca3:	55                   	push   %ebp
80104ca4:	89 e5                	mov    %esp,%ebp
80104ca6:	53                   	push   %ebx
80104ca7:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cad:	50                   	push   %eax
80104cae:	6a 00                	push   $0x0
80104cb0:	e8 b2 f2 ff ff       	call   80103f67 <argint>
80104cb5:	83 c4 10             	add    $0x10,%esp
80104cb8:	85 c0                	test   %eax,%eax
80104cba:	78 27                	js     80104ce3 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104cbc:	e8 0d e6 ff ff       	call   801032ce <myproc>
80104cc1:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104cc3:	83 ec 0c             	sub    $0xc,%esp
80104cc6:	ff 75 f4             	pushl  -0xc(%ebp)
80104cc9:	e8 0b e7 ff ff       	call   801033d9 <growproc>
80104cce:	83 c4 10             	add    $0x10,%esp
80104cd1:	85 c0                	test   %eax,%eax
80104cd3:	78 07                	js     80104cdc <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104cd5:	89 d8                	mov    %ebx,%eax
80104cd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cda:	c9                   	leave  
80104cdb:	c3                   	ret    
    return -1;
80104cdc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ce1:	eb f2                	jmp    80104cd5 <sys_sbrk+0x32>
    return -1;
80104ce3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ce8:	eb eb                	jmp    80104cd5 <sys_sbrk+0x32>

80104cea <sys_sleep>:

int
sys_sleep(void)
{
80104cea:	55                   	push   %ebp
80104ceb:	89 e5                	mov    %esp,%ebp
80104ced:	53                   	push   %ebx
80104cee:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104cf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cf4:	50                   	push   %eax
80104cf5:	6a 00                	push   $0x0
80104cf7:	e8 6b f2 ff ff       	call   80103f67 <argint>
80104cfc:	83 c4 10             	add    $0x10,%esp
80104cff:	85 c0                	test   %eax,%eax
80104d01:	78 75                	js     80104d78 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104d03:	83 ec 0c             	sub    $0xc,%esp
80104d06:	68 80 3c 13 80       	push   $0x80133c80
80104d0b:	e8 60 ef ff ff       	call   80103c70 <acquire>
  ticks0 = ticks;
80104d10:	8b 1d c0 44 13 80    	mov    0x801344c0,%ebx
  while(ticks - ticks0 < n){
80104d16:	83 c4 10             	add    $0x10,%esp
80104d19:	a1 c0 44 13 80       	mov    0x801344c0,%eax
80104d1e:	29 d8                	sub    %ebx,%eax
80104d20:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d23:	73 39                	jae    80104d5e <sys_sleep+0x74>
    if(myproc()->killed){
80104d25:	e8 a4 e5 ff ff       	call   801032ce <myproc>
80104d2a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104d2e:	75 17                	jne    80104d47 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104d30:	83 ec 08             	sub    $0x8,%esp
80104d33:	68 80 3c 13 80       	push   $0x80133c80
80104d38:	68 c0 44 13 80       	push   $0x801344c0
80104d3d:	e8 33 ea ff ff       	call   80103775 <sleep>
80104d42:	83 c4 10             	add    $0x10,%esp
80104d45:	eb d2                	jmp    80104d19 <sys_sleep+0x2f>
      release(&tickslock);
80104d47:	83 ec 0c             	sub    $0xc,%esp
80104d4a:	68 80 3c 13 80       	push   $0x80133c80
80104d4f:	e8 81 ef ff ff       	call   80103cd5 <release>
      return -1;
80104d54:	83 c4 10             	add    $0x10,%esp
80104d57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d5c:	eb 15                	jmp    80104d73 <sys_sleep+0x89>
  }
  release(&tickslock);
80104d5e:	83 ec 0c             	sub    $0xc,%esp
80104d61:	68 80 3c 13 80       	push   $0x80133c80
80104d66:	e8 6a ef ff ff       	call   80103cd5 <release>
  return 0;
80104d6b:	83 c4 10             	add    $0x10,%esp
80104d6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d76:	c9                   	leave  
80104d77:	c3                   	ret    
    return -1;
80104d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d7d:	eb f4                	jmp    80104d73 <sys_sleep+0x89>

80104d7f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d7f:	55                   	push   %ebp
80104d80:	89 e5                	mov    %esp,%ebp
80104d82:	53                   	push   %ebx
80104d83:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104d86:	68 80 3c 13 80       	push   $0x80133c80
80104d8b:	e8 e0 ee ff ff       	call   80103c70 <acquire>
  xticks = ticks;
80104d90:	8b 1d c0 44 13 80    	mov    0x801344c0,%ebx
  release(&tickslock);
80104d96:	c7 04 24 80 3c 13 80 	movl   $0x80133c80,(%esp)
80104d9d:	e8 33 ef ff ff       	call   80103cd5 <release>
  return xticks;
}
80104da2:	89 d8                	mov    %ebx,%eax
80104da4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104da7:	c9                   	leave  
80104da8:	c3                   	ret    

80104da9 <sys_dump_physmem>:

int
sys_dump_physmem(void) {
80104da9:	55                   	push   %ebp
80104daa:	89 e5                	mov    %esp,%ebp
80104dac:	83 ec 1c             	sub    $0x1c,%esp
    int* frames;
    int* pids;
    int numframes;
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104daf:	6a 04                	push   $0x4
80104db1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104db4:	50                   	push   %eax
80104db5:	6a 00                	push   $0x0
80104db7:	e8 d3 f1 ff ff       	call   80103f8f <argptr>
80104dbc:	83 c4 10             	add    $0x10,%esp
80104dbf:	85 c0                	test   %eax,%eax
80104dc1:	78 42                	js     80104e05 <sys_dump_physmem+0x5c>
80104dc3:	83 ec 04             	sub    $0x4,%esp
80104dc6:	6a 04                	push   $0x4
80104dc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104dcb:	50                   	push   %eax
80104dcc:	6a 01                	push   $0x1
80104dce:	e8 bc f1 ff ff       	call   80103f8f <argptr>
80104dd3:	83 c4 10             	add    $0x10,%esp
80104dd6:	85 c0                	test   %eax,%eax
80104dd8:	78 32                	js     80104e0c <sys_dump_physmem+0x63>
    argint(2, &numframes) < 0) {
80104dda:	83 ec 08             	sub    $0x8,%esp
80104ddd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104de0:	50                   	push   %eax
80104de1:	6a 02                	push   $0x2
80104de3:	e8 7f f1 ff ff       	call   80103f67 <argint>
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104de8:	83 c4 10             	add    $0x10,%esp
80104deb:	85 c0                	test   %eax,%eax
80104ded:	78 24                	js     80104e13 <sys_dump_physmem+0x6a>
        return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104def:	83 ec 04             	sub    $0x4,%esp
80104df2:	ff 75 ec             	pushl  -0x14(%ebp)
80104df5:	ff 75 f0             	pushl  -0x10(%ebp)
80104df8:	ff 75 f4             	pushl  -0xc(%ebp)
80104dfb:	e8 58 d3 ff ff       	call   80102158 <dump_physmem>
80104e00:	83 c4 10             	add    $0x10,%esp
80104e03:	c9                   	leave  
80104e04:	c3                   	ret    
        return -1;
80104e05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e0a:	eb f7                	jmp    80104e03 <sys_dump_physmem+0x5a>
80104e0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e11:	eb f0                	jmp    80104e03 <sys_dump_physmem+0x5a>
80104e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e18:	eb e9                	jmp    80104e03 <sys_dump_physmem+0x5a>

80104e1a <alltraps>:
80104e1a:	1e                   	push   %ds
80104e1b:	06                   	push   %es
80104e1c:	0f a0                	push   %fs
80104e1e:	0f a8                	push   %gs
80104e20:	60                   	pusha  
80104e21:	66 b8 10 00          	mov    $0x10,%ax
80104e25:	8e d8                	mov    %eax,%ds
80104e27:	8e c0                	mov    %eax,%es
80104e29:	54                   	push   %esp
80104e2a:	e8 e3 00 00 00       	call   80104f12 <trap>
80104e2f:	83 c4 04             	add    $0x4,%esp

80104e32 <trapret>:
80104e32:	61                   	popa   
80104e33:	0f a9                	pop    %gs
80104e35:	0f a1                	pop    %fs
80104e37:	07                   	pop    %es
80104e38:	1f                   	pop    %ds
80104e39:	83 c4 08             	add    $0x8,%esp
80104e3c:	cf                   	iret   

80104e3d <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104e3d:	55                   	push   %ebp
80104e3e:	89 e5                	mov    %esp,%ebp
80104e40:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104e43:	b8 00 00 00 00       	mov    $0x0,%eax
80104e48:	eb 4a                	jmp    80104e94 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104e4a:	8b 0c 85 08 90 12 80 	mov    -0x7fed6ff8(,%eax,4),%ecx
80104e51:	66 89 0c c5 c0 3c 13 	mov    %cx,-0x7fecc340(,%eax,8)
80104e58:	80 
80104e59:	66 c7 04 c5 c2 3c 13 	movw   $0x8,-0x7fecc33e(,%eax,8)
80104e60:	80 08 00 
80104e63:	c6 04 c5 c4 3c 13 80 	movb   $0x0,-0x7fecc33c(,%eax,8)
80104e6a:	00 
80104e6b:	0f b6 14 c5 c5 3c 13 	movzbl -0x7fecc33b(,%eax,8),%edx
80104e72:	80 
80104e73:	83 e2 f0             	and    $0xfffffff0,%edx
80104e76:	83 ca 0e             	or     $0xe,%edx
80104e79:	83 e2 8f             	and    $0xffffff8f,%edx
80104e7c:	83 ca 80             	or     $0xffffff80,%edx
80104e7f:	88 14 c5 c5 3c 13 80 	mov    %dl,-0x7fecc33b(,%eax,8)
80104e86:	c1 e9 10             	shr    $0x10,%ecx
80104e89:	66 89 0c c5 c6 3c 13 	mov    %cx,-0x7fecc33a(,%eax,8)
80104e90:	80 
  for(i = 0; i < 256; i++)
80104e91:	83 c0 01             	add    $0x1,%eax
80104e94:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e99:	7e af                	jle    80104e4a <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e9b:	8b 15 08 91 12 80    	mov    0x80129108,%edx
80104ea1:	66 89 15 c0 3e 13 80 	mov    %dx,0x80133ec0
80104ea8:	66 c7 05 c2 3e 13 80 	movw   $0x8,0x80133ec2
80104eaf:	08 00 
80104eb1:	c6 05 c4 3e 13 80 00 	movb   $0x0,0x80133ec4
80104eb8:	0f b6 05 c5 3e 13 80 	movzbl 0x80133ec5,%eax
80104ebf:	83 c8 0f             	or     $0xf,%eax
80104ec2:	83 e0 ef             	and    $0xffffffef,%eax
80104ec5:	83 c8 e0             	or     $0xffffffe0,%eax
80104ec8:	a2 c5 3e 13 80       	mov    %al,0x80133ec5
80104ecd:	c1 ea 10             	shr    $0x10,%edx
80104ed0:	66 89 15 c6 3e 13 80 	mov    %dx,0x80133ec6

  initlock(&tickslock, "time");
80104ed7:	83 ec 08             	sub    $0x8,%esp
80104eda:	68 3d 6d 10 80       	push   $0x80106d3d
80104edf:	68 80 3c 13 80       	push   $0x80133c80
80104ee4:	e8 4b ec ff ff       	call   80103b34 <initlock>
}
80104ee9:	83 c4 10             	add    $0x10,%esp
80104eec:	c9                   	leave  
80104eed:	c3                   	ret    

80104eee <idtinit>:

void
idtinit(void)
{
80104eee:	55                   	push   %ebp
80104eef:	89 e5                	mov    %esp,%ebp
80104ef1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104ef4:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104efa:	b8 c0 3c 13 80       	mov    $0x80133cc0,%eax
80104eff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104f03:	c1 e8 10             	shr    $0x10,%eax
80104f06:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104f0a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104f0d:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104f10:	c9                   	leave  
80104f11:	c3                   	ret    

80104f12 <trap>:

void
trap(struct trapframe *tf)
{
80104f12:	55                   	push   %ebp
80104f13:	89 e5                	mov    %esp,%ebp
80104f15:	57                   	push   %edi
80104f16:	56                   	push   %esi
80104f17:	53                   	push   %ebx
80104f18:	83 ec 1c             	sub    $0x1c,%esp
80104f1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104f1e:	8b 43 30             	mov    0x30(%ebx),%eax
80104f21:	83 f8 40             	cmp    $0x40,%eax
80104f24:	74 13                	je     80104f39 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104f26:	83 e8 20             	sub    $0x20,%eax
80104f29:	83 f8 1f             	cmp    $0x1f,%eax
80104f2c:	0f 87 3a 01 00 00    	ja     8010506c <trap+0x15a>
80104f32:	ff 24 85 e4 6d 10 80 	jmp    *-0x7fef921c(,%eax,4)
    if(myproc()->killed)
80104f39:	e8 90 e3 ff ff       	call   801032ce <myproc>
80104f3e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f42:	75 1f                	jne    80104f63 <trap+0x51>
    myproc()->tf = tf;
80104f44:	e8 85 e3 ff ff       	call   801032ce <myproc>
80104f49:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104f4c:	e8 d9 f0 ff ff       	call   8010402a <syscall>
    if(myproc()->killed)
80104f51:	e8 78 e3 ff ff       	call   801032ce <myproc>
80104f56:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f5a:	74 7e                	je     80104fda <trap+0xc8>
      exit();
80104f5c:	e8 1c e7 ff ff       	call   8010367d <exit>
80104f61:	eb 77                	jmp    80104fda <trap+0xc8>
      exit();
80104f63:	e8 15 e7 ff ff       	call   8010367d <exit>
80104f68:	eb da                	jmp    80104f44 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104f6a:	e8 44 e3 ff ff       	call   801032b3 <cpuid>
80104f6f:	85 c0                	test   %eax,%eax
80104f71:	74 6f                	je     80104fe2 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104f73:	e8 e6 d4 ff ff       	call   8010245e <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f78:	e8 51 e3 ff ff       	call   801032ce <myproc>
80104f7d:	85 c0                	test   %eax,%eax
80104f7f:	74 1c                	je     80104f9d <trap+0x8b>
80104f81:	e8 48 e3 ff ff       	call   801032ce <myproc>
80104f86:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f8a:	74 11                	je     80104f9d <trap+0x8b>
80104f8c:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f90:	83 e0 03             	and    $0x3,%eax
80104f93:	66 83 f8 03          	cmp    $0x3,%ax
80104f97:	0f 84 62 01 00 00    	je     801050ff <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f9d:	e8 2c e3 ff ff       	call   801032ce <myproc>
80104fa2:	85 c0                	test   %eax,%eax
80104fa4:	74 0f                	je     80104fb5 <trap+0xa3>
80104fa6:	e8 23 e3 ff ff       	call   801032ce <myproc>
80104fab:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104faf:	0f 84 54 01 00 00    	je     80105109 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104fb5:	e8 14 e3 ff ff       	call   801032ce <myproc>
80104fba:	85 c0                	test   %eax,%eax
80104fbc:	74 1c                	je     80104fda <trap+0xc8>
80104fbe:	e8 0b e3 ff ff       	call   801032ce <myproc>
80104fc3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fc7:	74 11                	je     80104fda <trap+0xc8>
80104fc9:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104fcd:	83 e0 03             	and    $0x3,%eax
80104fd0:	66 83 f8 03          	cmp    $0x3,%ax
80104fd4:	0f 84 43 01 00 00    	je     8010511d <trap+0x20b>
    exit();
}
80104fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104fdd:	5b                   	pop    %ebx
80104fde:	5e                   	pop    %esi
80104fdf:	5f                   	pop    %edi
80104fe0:	5d                   	pop    %ebp
80104fe1:	c3                   	ret    
      acquire(&tickslock);
80104fe2:	83 ec 0c             	sub    $0xc,%esp
80104fe5:	68 80 3c 13 80       	push   $0x80133c80
80104fea:	e8 81 ec ff ff       	call   80103c70 <acquire>
      ticks++;
80104fef:	83 05 c0 44 13 80 01 	addl   $0x1,0x801344c0
      wakeup(&ticks);
80104ff6:	c7 04 24 c0 44 13 80 	movl   $0x801344c0,(%esp)
80104ffd:	e8 d8 e8 ff ff       	call   801038da <wakeup>
      release(&tickslock);
80105002:	c7 04 24 80 3c 13 80 	movl   $0x80133c80,(%esp)
80105009:	e8 c7 ec ff ff       	call   80103cd5 <release>
8010500e:	83 c4 10             	add    $0x10,%esp
80105011:	e9 5d ff ff ff       	jmp    80104f73 <trap+0x61>
    ideintr();
80105016:	e8 64 cd ff ff       	call   80101d7f <ideintr>
    lapiceoi();
8010501b:	e8 3e d4 ff ff       	call   8010245e <lapiceoi>
    break;
80105020:	e9 53 ff ff ff       	jmp    80104f78 <trap+0x66>
    kbdintr();
80105025:	e8 78 d2 ff ff       	call   801022a2 <kbdintr>
    lapiceoi();
8010502a:	e8 2f d4 ff ff       	call   8010245e <lapiceoi>
    break;
8010502f:	e9 44 ff ff ff       	jmp    80104f78 <trap+0x66>
    uartintr();
80105034:	e8 05 02 00 00       	call   8010523e <uartintr>
    lapiceoi();
80105039:	e8 20 d4 ff ff       	call   8010245e <lapiceoi>
    break;
8010503e:	e9 35 ff ff ff       	jmp    80104f78 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105043:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105046:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010504a:	e8 64 e2 ff ff       	call   801032b3 <cpuid>
8010504f:	57                   	push   %edi
80105050:	0f b7 f6             	movzwl %si,%esi
80105053:	56                   	push   %esi
80105054:	50                   	push   %eax
80105055:	68 48 6d 10 80       	push   $0x80106d48
8010505a:	e8 ac b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
8010505f:	e8 fa d3 ff ff       	call   8010245e <lapiceoi>
    break;
80105064:	83 c4 10             	add    $0x10,%esp
80105067:	e9 0c ff ff ff       	jmp    80104f78 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010506c:	e8 5d e2 ff ff       	call   801032ce <myproc>
80105071:	85 c0                	test   %eax,%eax
80105073:	74 5f                	je     801050d4 <trap+0x1c2>
80105075:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105079:	74 59                	je     801050d4 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010507b:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010507e:	8b 43 38             	mov    0x38(%ebx),%eax
80105081:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105084:	e8 2a e2 ff ff       	call   801032b3 <cpuid>
80105089:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010508c:	8b 53 34             	mov    0x34(%ebx),%edx
8010508f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105092:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105095:	e8 34 e2 ff ff       	call   801032ce <myproc>
8010509a:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010509d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801050a0:	e8 29 e2 ff ff       	call   801032ce <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801050a5:	57                   	push   %edi
801050a6:	ff 75 e4             	pushl  -0x1c(%ebp)
801050a9:	ff 75 e0             	pushl  -0x20(%ebp)
801050ac:	ff 75 dc             	pushl  -0x24(%ebp)
801050af:	56                   	push   %esi
801050b0:	ff 75 d8             	pushl  -0x28(%ebp)
801050b3:	ff 70 10             	pushl  0x10(%eax)
801050b6:	68 a0 6d 10 80       	push   $0x80106da0
801050bb:	e8 4b b5 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801050c0:	83 c4 20             	add    $0x20,%esp
801050c3:	e8 06 e2 ff ff       	call   801032ce <myproc>
801050c8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801050cf:	e9 a4 fe ff ff       	jmp    80104f78 <trap+0x66>
801050d4:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801050d7:	8b 73 38             	mov    0x38(%ebx),%esi
801050da:	e8 d4 e1 ff ff       	call   801032b3 <cpuid>
801050df:	83 ec 0c             	sub    $0xc,%esp
801050e2:	57                   	push   %edi
801050e3:	56                   	push   %esi
801050e4:	50                   	push   %eax
801050e5:	ff 73 30             	pushl  0x30(%ebx)
801050e8:	68 6c 6d 10 80       	push   $0x80106d6c
801050ed:	e8 19 b5 ff ff       	call   8010060b <cprintf>
      panic("trap");
801050f2:	83 c4 14             	add    $0x14,%esp
801050f5:	68 42 6d 10 80       	push   $0x80106d42
801050fa:	e8 49 b2 ff ff       	call   80100348 <panic>
    exit();
801050ff:	e8 79 e5 ff ff       	call   8010367d <exit>
80105104:	e9 94 fe ff ff       	jmp    80104f9d <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105109:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010510d:	0f 85 a2 fe ff ff    	jne    80104fb5 <trap+0xa3>
    yield();
80105113:	e8 2b e6 ff ff       	call   80103743 <yield>
80105118:	e9 98 fe ff ff       	jmp    80104fb5 <trap+0xa3>
    exit();
8010511d:	e8 5b e5 ff ff       	call   8010367d <exit>
80105122:	e9 b3 fe ff ff       	jmp    80104fda <trap+0xc8>

80105127 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010512a:	83 3d c0 95 12 80 00 	cmpl   $0x0,0x801295c0
80105131:	74 15                	je     80105148 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105133:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105138:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105139:	a8 01                	test   $0x1,%al
8010513b:	74 12                	je     8010514f <uartgetc+0x28>
8010513d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105142:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105143:	0f b6 c0             	movzbl %al,%eax
}
80105146:	5d                   	pop    %ebp
80105147:	c3                   	ret    
    return -1;
80105148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010514d:	eb f7                	jmp    80105146 <uartgetc+0x1f>
    return -1;
8010514f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105154:	eb f0                	jmp    80105146 <uartgetc+0x1f>

80105156 <uartputc>:
  if(!uart)
80105156:	83 3d c0 95 12 80 00 	cmpl   $0x0,0x801295c0
8010515d:	74 3b                	je     8010519a <uartputc+0x44>
{
8010515f:	55                   	push   %ebp
80105160:	89 e5                	mov    %esp,%ebp
80105162:	53                   	push   %ebx
80105163:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105166:	bb 00 00 00 00       	mov    $0x0,%ebx
8010516b:	eb 10                	jmp    8010517d <uartputc+0x27>
    microdelay(10);
8010516d:	83 ec 0c             	sub    $0xc,%esp
80105170:	6a 0a                	push   $0xa
80105172:	e8 06 d3 ff ff       	call   8010247d <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105177:	83 c3 01             	add    $0x1,%ebx
8010517a:	83 c4 10             	add    $0x10,%esp
8010517d:	83 fb 7f             	cmp    $0x7f,%ebx
80105180:	7f 0a                	jg     8010518c <uartputc+0x36>
80105182:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105187:	ec                   	in     (%dx),%al
80105188:	a8 20                	test   $0x20,%al
8010518a:	74 e1                	je     8010516d <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010518c:	8b 45 08             	mov    0x8(%ebp),%eax
8010518f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105194:	ee                   	out    %al,(%dx)
}
80105195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105198:	c9                   	leave  
80105199:	c3                   	ret    
8010519a:	f3 c3                	repz ret 

8010519c <uartinit>:
{
8010519c:	55                   	push   %ebp
8010519d:	89 e5                	mov    %esp,%ebp
8010519f:	56                   	push   %esi
801051a0:	53                   	push   %ebx
801051a1:	b9 00 00 00 00       	mov    $0x0,%ecx
801051a6:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051ab:	89 c8                	mov    %ecx,%eax
801051ad:	ee                   	out    %al,(%dx)
801051ae:	be fb 03 00 00       	mov    $0x3fb,%esi
801051b3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801051b8:	89 f2                	mov    %esi,%edx
801051ba:	ee                   	out    %al,(%dx)
801051bb:	b8 0c 00 00 00       	mov    $0xc,%eax
801051c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051c5:	ee                   	out    %al,(%dx)
801051c6:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801051cb:	89 c8                	mov    %ecx,%eax
801051cd:	89 da                	mov    %ebx,%edx
801051cf:	ee                   	out    %al,(%dx)
801051d0:	b8 03 00 00 00       	mov    $0x3,%eax
801051d5:	89 f2                	mov    %esi,%edx
801051d7:	ee                   	out    %al,(%dx)
801051d8:	ba fc 03 00 00       	mov    $0x3fc,%edx
801051dd:	89 c8                	mov    %ecx,%eax
801051df:	ee                   	out    %al,(%dx)
801051e0:	b8 01 00 00 00       	mov    $0x1,%eax
801051e5:	89 da                	mov    %ebx,%edx
801051e7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051e8:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051ed:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801051ee:	3c ff                	cmp    $0xff,%al
801051f0:	74 45                	je     80105237 <uartinit+0x9b>
  uart = 1;
801051f2:	c7 05 c0 95 12 80 01 	movl   $0x1,0x801295c0
801051f9:	00 00 00 
801051fc:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105201:	ec                   	in     (%dx),%al
80105202:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105207:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105208:	83 ec 08             	sub    $0x8,%esp
8010520b:	6a 00                	push   $0x0
8010520d:	6a 04                	push   $0x4
8010520f:	e8 76 cd ff ff       	call   80101f8a <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105214:	83 c4 10             	add    $0x10,%esp
80105217:	bb 64 6e 10 80       	mov    $0x80106e64,%ebx
8010521c:	eb 12                	jmp    80105230 <uartinit+0x94>
    uartputc(*p);
8010521e:	83 ec 0c             	sub    $0xc,%esp
80105221:	0f be c0             	movsbl %al,%eax
80105224:	50                   	push   %eax
80105225:	e8 2c ff ff ff       	call   80105156 <uartputc>
  for(p="xv6...\n"; *p; p++)
8010522a:	83 c3 01             	add    $0x1,%ebx
8010522d:	83 c4 10             	add    $0x10,%esp
80105230:	0f b6 03             	movzbl (%ebx),%eax
80105233:	84 c0                	test   %al,%al
80105235:	75 e7                	jne    8010521e <uartinit+0x82>
}
80105237:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010523a:	5b                   	pop    %ebx
8010523b:	5e                   	pop    %esi
8010523c:	5d                   	pop    %ebp
8010523d:	c3                   	ret    

8010523e <uartintr>:

void
uartintr(void)
{
8010523e:	55                   	push   %ebp
8010523f:	89 e5                	mov    %esp,%ebp
80105241:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105244:	68 27 51 10 80       	push   $0x80105127
80105249:	e8 f0 b4 ff ff       	call   8010073e <consoleintr>
}
8010524e:	83 c4 10             	add    $0x10,%esp
80105251:	c9                   	leave  
80105252:	c3                   	ret    

80105253 <vector0>:
80105253:	6a 00                	push   $0x0
80105255:	6a 00                	push   $0x0
80105257:	e9 be fb ff ff       	jmp    80104e1a <alltraps>

8010525c <vector1>:
8010525c:	6a 00                	push   $0x0
8010525e:	6a 01                	push   $0x1
80105260:	e9 b5 fb ff ff       	jmp    80104e1a <alltraps>

80105265 <vector2>:
80105265:	6a 00                	push   $0x0
80105267:	6a 02                	push   $0x2
80105269:	e9 ac fb ff ff       	jmp    80104e1a <alltraps>

8010526e <vector3>:
8010526e:	6a 00                	push   $0x0
80105270:	6a 03                	push   $0x3
80105272:	e9 a3 fb ff ff       	jmp    80104e1a <alltraps>

80105277 <vector4>:
80105277:	6a 00                	push   $0x0
80105279:	6a 04                	push   $0x4
8010527b:	e9 9a fb ff ff       	jmp    80104e1a <alltraps>

80105280 <vector5>:
80105280:	6a 00                	push   $0x0
80105282:	6a 05                	push   $0x5
80105284:	e9 91 fb ff ff       	jmp    80104e1a <alltraps>

80105289 <vector6>:
80105289:	6a 00                	push   $0x0
8010528b:	6a 06                	push   $0x6
8010528d:	e9 88 fb ff ff       	jmp    80104e1a <alltraps>

80105292 <vector7>:
80105292:	6a 00                	push   $0x0
80105294:	6a 07                	push   $0x7
80105296:	e9 7f fb ff ff       	jmp    80104e1a <alltraps>

8010529b <vector8>:
8010529b:	6a 08                	push   $0x8
8010529d:	e9 78 fb ff ff       	jmp    80104e1a <alltraps>

801052a2 <vector9>:
801052a2:	6a 00                	push   $0x0
801052a4:	6a 09                	push   $0x9
801052a6:	e9 6f fb ff ff       	jmp    80104e1a <alltraps>

801052ab <vector10>:
801052ab:	6a 0a                	push   $0xa
801052ad:	e9 68 fb ff ff       	jmp    80104e1a <alltraps>

801052b2 <vector11>:
801052b2:	6a 0b                	push   $0xb
801052b4:	e9 61 fb ff ff       	jmp    80104e1a <alltraps>

801052b9 <vector12>:
801052b9:	6a 0c                	push   $0xc
801052bb:	e9 5a fb ff ff       	jmp    80104e1a <alltraps>

801052c0 <vector13>:
801052c0:	6a 0d                	push   $0xd
801052c2:	e9 53 fb ff ff       	jmp    80104e1a <alltraps>

801052c7 <vector14>:
801052c7:	6a 0e                	push   $0xe
801052c9:	e9 4c fb ff ff       	jmp    80104e1a <alltraps>

801052ce <vector15>:
801052ce:	6a 00                	push   $0x0
801052d0:	6a 0f                	push   $0xf
801052d2:	e9 43 fb ff ff       	jmp    80104e1a <alltraps>

801052d7 <vector16>:
801052d7:	6a 00                	push   $0x0
801052d9:	6a 10                	push   $0x10
801052db:	e9 3a fb ff ff       	jmp    80104e1a <alltraps>

801052e0 <vector17>:
801052e0:	6a 11                	push   $0x11
801052e2:	e9 33 fb ff ff       	jmp    80104e1a <alltraps>

801052e7 <vector18>:
801052e7:	6a 00                	push   $0x0
801052e9:	6a 12                	push   $0x12
801052eb:	e9 2a fb ff ff       	jmp    80104e1a <alltraps>

801052f0 <vector19>:
801052f0:	6a 00                	push   $0x0
801052f2:	6a 13                	push   $0x13
801052f4:	e9 21 fb ff ff       	jmp    80104e1a <alltraps>

801052f9 <vector20>:
801052f9:	6a 00                	push   $0x0
801052fb:	6a 14                	push   $0x14
801052fd:	e9 18 fb ff ff       	jmp    80104e1a <alltraps>

80105302 <vector21>:
80105302:	6a 00                	push   $0x0
80105304:	6a 15                	push   $0x15
80105306:	e9 0f fb ff ff       	jmp    80104e1a <alltraps>

8010530b <vector22>:
8010530b:	6a 00                	push   $0x0
8010530d:	6a 16                	push   $0x16
8010530f:	e9 06 fb ff ff       	jmp    80104e1a <alltraps>

80105314 <vector23>:
80105314:	6a 00                	push   $0x0
80105316:	6a 17                	push   $0x17
80105318:	e9 fd fa ff ff       	jmp    80104e1a <alltraps>

8010531d <vector24>:
8010531d:	6a 00                	push   $0x0
8010531f:	6a 18                	push   $0x18
80105321:	e9 f4 fa ff ff       	jmp    80104e1a <alltraps>

80105326 <vector25>:
80105326:	6a 00                	push   $0x0
80105328:	6a 19                	push   $0x19
8010532a:	e9 eb fa ff ff       	jmp    80104e1a <alltraps>

8010532f <vector26>:
8010532f:	6a 00                	push   $0x0
80105331:	6a 1a                	push   $0x1a
80105333:	e9 e2 fa ff ff       	jmp    80104e1a <alltraps>

80105338 <vector27>:
80105338:	6a 00                	push   $0x0
8010533a:	6a 1b                	push   $0x1b
8010533c:	e9 d9 fa ff ff       	jmp    80104e1a <alltraps>

80105341 <vector28>:
80105341:	6a 00                	push   $0x0
80105343:	6a 1c                	push   $0x1c
80105345:	e9 d0 fa ff ff       	jmp    80104e1a <alltraps>

8010534a <vector29>:
8010534a:	6a 00                	push   $0x0
8010534c:	6a 1d                	push   $0x1d
8010534e:	e9 c7 fa ff ff       	jmp    80104e1a <alltraps>

80105353 <vector30>:
80105353:	6a 00                	push   $0x0
80105355:	6a 1e                	push   $0x1e
80105357:	e9 be fa ff ff       	jmp    80104e1a <alltraps>

8010535c <vector31>:
8010535c:	6a 00                	push   $0x0
8010535e:	6a 1f                	push   $0x1f
80105360:	e9 b5 fa ff ff       	jmp    80104e1a <alltraps>

80105365 <vector32>:
80105365:	6a 00                	push   $0x0
80105367:	6a 20                	push   $0x20
80105369:	e9 ac fa ff ff       	jmp    80104e1a <alltraps>

8010536e <vector33>:
8010536e:	6a 00                	push   $0x0
80105370:	6a 21                	push   $0x21
80105372:	e9 a3 fa ff ff       	jmp    80104e1a <alltraps>

80105377 <vector34>:
80105377:	6a 00                	push   $0x0
80105379:	6a 22                	push   $0x22
8010537b:	e9 9a fa ff ff       	jmp    80104e1a <alltraps>

80105380 <vector35>:
80105380:	6a 00                	push   $0x0
80105382:	6a 23                	push   $0x23
80105384:	e9 91 fa ff ff       	jmp    80104e1a <alltraps>

80105389 <vector36>:
80105389:	6a 00                	push   $0x0
8010538b:	6a 24                	push   $0x24
8010538d:	e9 88 fa ff ff       	jmp    80104e1a <alltraps>

80105392 <vector37>:
80105392:	6a 00                	push   $0x0
80105394:	6a 25                	push   $0x25
80105396:	e9 7f fa ff ff       	jmp    80104e1a <alltraps>

8010539b <vector38>:
8010539b:	6a 00                	push   $0x0
8010539d:	6a 26                	push   $0x26
8010539f:	e9 76 fa ff ff       	jmp    80104e1a <alltraps>

801053a4 <vector39>:
801053a4:	6a 00                	push   $0x0
801053a6:	6a 27                	push   $0x27
801053a8:	e9 6d fa ff ff       	jmp    80104e1a <alltraps>

801053ad <vector40>:
801053ad:	6a 00                	push   $0x0
801053af:	6a 28                	push   $0x28
801053b1:	e9 64 fa ff ff       	jmp    80104e1a <alltraps>

801053b6 <vector41>:
801053b6:	6a 00                	push   $0x0
801053b8:	6a 29                	push   $0x29
801053ba:	e9 5b fa ff ff       	jmp    80104e1a <alltraps>

801053bf <vector42>:
801053bf:	6a 00                	push   $0x0
801053c1:	6a 2a                	push   $0x2a
801053c3:	e9 52 fa ff ff       	jmp    80104e1a <alltraps>

801053c8 <vector43>:
801053c8:	6a 00                	push   $0x0
801053ca:	6a 2b                	push   $0x2b
801053cc:	e9 49 fa ff ff       	jmp    80104e1a <alltraps>

801053d1 <vector44>:
801053d1:	6a 00                	push   $0x0
801053d3:	6a 2c                	push   $0x2c
801053d5:	e9 40 fa ff ff       	jmp    80104e1a <alltraps>

801053da <vector45>:
801053da:	6a 00                	push   $0x0
801053dc:	6a 2d                	push   $0x2d
801053de:	e9 37 fa ff ff       	jmp    80104e1a <alltraps>

801053e3 <vector46>:
801053e3:	6a 00                	push   $0x0
801053e5:	6a 2e                	push   $0x2e
801053e7:	e9 2e fa ff ff       	jmp    80104e1a <alltraps>

801053ec <vector47>:
801053ec:	6a 00                	push   $0x0
801053ee:	6a 2f                	push   $0x2f
801053f0:	e9 25 fa ff ff       	jmp    80104e1a <alltraps>

801053f5 <vector48>:
801053f5:	6a 00                	push   $0x0
801053f7:	6a 30                	push   $0x30
801053f9:	e9 1c fa ff ff       	jmp    80104e1a <alltraps>

801053fe <vector49>:
801053fe:	6a 00                	push   $0x0
80105400:	6a 31                	push   $0x31
80105402:	e9 13 fa ff ff       	jmp    80104e1a <alltraps>

80105407 <vector50>:
80105407:	6a 00                	push   $0x0
80105409:	6a 32                	push   $0x32
8010540b:	e9 0a fa ff ff       	jmp    80104e1a <alltraps>

80105410 <vector51>:
80105410:	6a 00                	push   $0x0
80105412:	6a 33                	push   $0x33
80105414:	e9 01 fa ff ff       	jmp    80104e1a <alltraps>

80105419 <vector52>:
80105419:	6a 00                	push   $0x0
8010541b:	6a 34                	push   $0x34
8010541d:	e9 f8 f9 ff ff       	jmp    80104e1a <alltraps>

80105422 <vector53>:
80105422:	6a 00                	push   $0x0
80105424:	6a 35                	push   $0x35
80105426:	e9 ef f9 ff ff       	jmp    80104e1a <alltraps>

8010542b <vector54>:
8010542b:	6a 00                	push   $0x0
8010542d:	6a 36                	push   $0x36
8010542f:	e9 e6 f9 ff ff       	jmp    80104e1a <alltraps>

80105434 <vector55>:
80105434:	6a 00                	push   $0x0
80105436:	6a 37                	push   $0x37
80105438:	e9 dd f9 ff ff       	jmp    80104e1a <alltraps>

8010543d <vector56>:
8010543d:	6a 00                	push   $0x0
8010543f:	6a 38                	push   $0x38
80105441:	e9 d4 f9 ff ff       	jmp    80104e1a <alltraps>

80105446 <vector57>:
80105446:	6a 00                	push   $0x0
80105448:	6a 39                	push   $0x39
8010544a:	e9 cb f9 ff ff       	jmp    80104e1a <alltraps>

8010544f <vector58>:
8010544f:	6a 00                	push   $0x0
80105451:	6a 3a                	push   $0x3a
80105453:	e9 c2 f9 ff ff       	jmp    80104e1a <alltraps>

80105458 <vector59>:
80105458:	6a 00                	push   $0x0
8010545a:	6a 3b                	push   $0x3b
8010545c:	e9 b9 f9 ff ff       	jmp    80104e1a <alltraps>

80105461 <vector60>:
80105461:	6a 00                	push   $0x0
80105463:	6a 3c                	push   $0x3c
80105465:	e9 b0 f9 ff ff       	jmp    80104e1a <alltraps>

8010546a <vector61>:
8010546a:	6a 00                	push   $0x0
8010546c:	6a 3d                	push   $0x3d
8010546e:	e9 a7 f9 ff ff       	jmp    80104e1a <alltraps>

80105473 <vector62>:
80105473:	6a 00                	push   $0x0
80105475:	6a 3e                	push   $0x3e
80105477:	e9 9e f9 ff ff       	jmp    80104e1a <alltraps>

8010547c <vector63>:
8010547c:	6a 00                	push   $0x0
8010547e:	6a 3f                	push   $0x3f
80105480:	e9 95 f9 ff ff       	jmp    80104e1a <alltraps>

80105485 <vector64>:
80105485:	6a 00                	push   $0x0
80105487:	6a 40                	push   $0x40
80105489:	e9 8c f9 ff ff       	jmp    80104e1a <alltraps>

8010548e <vector65>:
8010548e:	6a 00                	push   $0x0
80105490:	6a 41                	push   $0x41
80105492:	e9 83 f9 ff ff       	jmp    80104e1a <alltraps>

80105497 <vector66>:
80105497:	6a 00                	push   $0x0
80105499:	6a 42                	push   $0x42
8010549b:	e9 7a f9 ff ff       	jmp    80104e1a <alltraps>

801054a0 <vector67>:
801054a0:	6a 00                	push   $0x0
801054a2:	6a 43                	push   $0x43
801054a4:	e9 71 f9 ff ff       	jmp    80104e1a <alltraps>

801054a9 <vector68>:
801054a9:	6a 00                	push   $0x0
801054ab:	6a 44                	push   $0x44
801054ad:	e9 68 f9 ff ff       	jmp    80104e1a <alltraps>

801054b2 <vector69>:
801054b2:	6a 00                	push   $0x0
801054b4:	6a 45                	push   $0x45
801054b6:	e9 5f f9 ff ff       	jmp    80104e1a <alltraps>

801054bb <vector70>:
801054bb:	6a 00                	push   $0x0
801054bd:	6a 46                	push   $0x46
801054bf:	e9 56 f9 ff ff       	jmp    80104e1a <alltraps>

801054c4 <vector71>:
801054c4:	6a 00                	push   $0x0
801054c6:	6a 47                	push   $0x47
801054c8:	e9 4d f9 ff ff       	jmp    80104e1a <alltraps>

801054cd <vector72>:
801054cd:	6a 00                	push   $0x0
801054cf:	6a 48                	push   $0x48
801054d1:	e9 44 f9 ff ff       	jmp    80104e1a <alltraps>

801054d6 <vector73>:
801054d6:	6a 00                	push   $0x0
801054d8:	6a 49                	push   $0x49
801054da:	e9 3b f9 ff ff       	jmp    80104e1a <alltraps>

801054df <vector74>:
801054df:	6a 00                	push   $0x0
801054e1:	6a 4a                	push   $0x4a
801054e3:	e9 32 f9 ff ff       	jmp    80104e1a <alltraps>

801054e8 <vector75>:
801054e8:	6a 00                	push   $0x0
801054ea:	6a 4b                	push   $0x4b
801054ec:	e9 29 f9 ff ff       	jmp    80104e1a <alltraps>

801054f1 <vector76>:
801054f1:	6a 00                	push   $0x0
801054f3:	6a 4c                	push   $0x4c
801054f5:	e9 20 f9 ff ff       	jmp    80104e1a <alltraps>

801054fa <vector77>:
801054fa:	6a 00                	push   $0x0
801054fc:	6a 4d                	push   $0x4d
801054fe:	e9 17 f9 ff ff       	jmp    80104e1a <alltraps>

80105503 <vector78>:
80105503:	6a 00                	push   $0x0
80105505:	6a 4e                	push   $0x4e
80105507:	e9 0e f9 ff ff       	jmp    80104e1a <alltraps>

8010550c <vector79>:
8010550c:	6a 00                	push   $0x0
8010550e:	6a 4f                	push   $0x4f
80105510:	e9 05 f9 ff ff       	jmp    80104e1a <alltraps>

80105515 <vector80>:
80105515:	6a 00                	push   $0x0
80105517:	6a 50                	push   $0x50
80105519:	e9 fc f8 ff ff       	jmp    80104e1a <alltraps>

8010551e <vector81>:
8010551e:	6a 00                	push   $0x0
80105520:	6a 51                	push   $0x51
80105522:	e9 f3 f8 ff ff       	jmp    80104e1a <alltraps>

80105527 <vector82>:
80105527:	6a 00                	push   $0x0
80105529:	6a 52                	push   $0x52
8010552b:	e9 ea f8 ff ff       	jmp    80104e1a <alltraps>

80105530 <vector83>:
80105530:	6a 00                	push   $0x0
80105532:	6a 53                	push   $0x53
80105534:	e9 e1 f8 ff ff       	jmp    80104e1a <alltraps>

80105539 <vector84>:
80105539:	6a 00                	push   $0x0
8010553b:	6a 54                	push   $0x54
8010553d:	e9 d8 f8 ff ff       	jmp    80104e1a <alltraps>

80105542 <vector85>:
80105542:	6a 00                	push   $0x0
80105544:	6a 55                	push   $0x55
80105546:	e9 cf f8 ff ff       	jmp    80104e1a <alltraps>

8010554b <vector86>:
8010554b:	6a 00                	push   $0x0
8010554d:	6a 56                	push   $0x56
8010554f:	e9 c6 f8 ff ff       	jmp    80104e1a <alltraps>

80105554 <vector87>:
80105554:	6a 00                	push   $0x0
80105556:	6a 57                	push   $0x57
80105558:	e9 bd f8 ff ff       	jmp    80104e1a <alltraps>

8010555d <vector88>:
8010555d:	6a 00                	push   $0x0
8010555f:	6a 58                	push   $0x58
80105561:	e9 b4 f8 ff ff       	jmp    80104e1a <alltraps>

80105566 <vector89>:
80105566:	6a 00                	push   $0x0
80105568:	6a 59                	push   $0x59
8010556a:	e9 ab f8 ff ff       	jmp    80104e1a <alltraps>

8010556f <vector90>:
8010556f:	6a 00                	push   $0x0
80105571:	6a 5a                	push   $0x5a
80105573:	e9 a2 f8 ff ff       	jmp    80104e1a <alltraps>

80105578 <vector91>:
80105578:	6a 00                	push   $0x0
8010557a:	6a 5b                	push   $0x5b
8010557c:	e9 99 f8 ff ff       	jmp    80104e1a <alltraps>

80105581 <vector92>:
80105581:	6a 00                	push   $0x0
80105583:	6a 5c                	push   $0x5c
80105585:	e9 90 f8 ff ff       	jmp    80104e1a <alltraps>

8010558a <vector93>:
8010558a:	6a 00                	push   $0x0
8010558c:	6a 5d                	push   $0x5d
8010558e:	e9 87 f8 ff ff       	jmp    80104e1a <alltraps>

80105593 <vector94>:
80105593:	6a 00                	push   $0x0
80105595:	6a 5e                	push   $0x5e
80105597:	e9 7e f8 ff ff       	jmp    80104e1a <alltraps>

8010559c <vector95>:
8010559c:	6a 00                	push   $0x0
8010559e:	6a 5f                	push   $0x5f
801055a0:	e9 75 f8 ff ff       	jmp    80104e1a <alltraps>

801055a5 <vector96>:
801055a5:	6a 00                	push   $0x0
801055a7:	6a 60                	push   $0x60
801055a9:	e9 6c f8 ff ff       	jmp    80104e1a <alltraps>

801055ae <vector97>:
801055ae:	6a 00                	push   $0x0
801055b0:	6a 61                	push   $0x61
801055b2:	e9 63 f8 ff ff       	jmp    80104e1a <alltraps>

801055b7 <vector98>:
801055b7:	6a 00                	push   $0x0
801055b9:	6a 62                	push   $0x62
801055bb:	e9 5a f8 ff ff       	jmp    80104e1a <alltraps>

801055c0 <vector99>:
801055c0:	6a 00                	push   $0x0
801055c2:	6a 63                	push   $0x63
801055c4:	e9 51 f8 ff ff       	jmp    80104e1a <alltraps>

801055c9 <vector100>:
801055c9:	6a 00                	push   $0x0
801055cb:	6a 64                	push   $0x64
801055cd:	e9 48 f8 ff ff       	jmp    80104e1a <alltraps>

801055d2 <vector101>:
801055d2:	6a 00                	push   $0x0
801055d4:	6a 65                	push   $0x65
801055d6:	e9 3f f8 ff ff       	jmp    80104e1a <alltraps>

801055db <vector102>:
801055db:	6a 00                	push   $0x0
801055dd:	6a 66                	push   $0x66
801055df:	e9 36 f8 ff ff       	jmp    80104e1a <alltraps>

801055e4 <vector103>:
801055e4:	6a 00                	push   $0x0
801055e6:	6a 67                	push   $0x67
801055e8:	e9 2d f8 ff ff       	jmp    80104e1a <alltraps>

801055ed <vector104>:
801055ed:	6a 00                	push   $0x0
801055ef:	6a 68                	push   $0x68
801055f1:	e9 24 f8 ff ff       	jmp    80104e1a <alltraps>

801055f6 <vector105>:
801055f6:	6a 00                	push   $0x0
801055f8:	6a 69                	push   $0x69
801055fa:	e9 1b f8 ff ff       	jmp    80104e1a <alltraps>

801055ff <vector106>:
801055ff:	6a 00                	push   $0x0
80105601:	6a 6a                	push   $0x6a
80105603:	e9 12 f8 ff ff       	jmp    80104e1a <alltraps>

80105608 <vector107>:
80105608:	6a 00                	push   $0x0
8010560a:	6a 6b                	push   $0x6b
8010560c:	e9 09 f8 ff ff       	jmp    80104e1a <alltraps>

80105611 <vector108>:
80105611:	6a 00                	push   $0x0
80105613:	6a 6c                	push   $0x6c
80105615:	e9 00 f8 ff ff       	jmp    80104e1a <alltraps>

8010561a <vector109>:
8010561a:	6a 00                	push   $0x0
8010561c:	6a 6d                	push   $0x6d
8010561e:	e9 f7 f7 ff ff       	jmp    80104e1a <alltraps>

80105623 <vector110>:
80105623:	6a 00                	push   $0x0
80105625:	6a 6e                	push   $0x6e
80105627:	e9 ee f7 ff ff       	jmp    80104e1a <alltraps>

8010562c <vector111>:
8010562c:	6a 00                	push   $0x0
8010562e:	6a 6f                	push   $0x6f
80105630:	e9 e5 f7 ff ff       	jmp    80104e1a <alltraps>

80105635 <vector112>:
80105635:	6a 00                	push   $0x0
80105637:	6a 70                	push   $0x70
80105639:	e9 dc f7 ff ff       	jmp    80104e1a <alltraps>

8010563e <vector113>:
8010563e:	6a 00                	push   $0x0
80105640:	6a 71                	push   $0x71
80105642:	e9 d3 f7 ff ff       	jmp    80104e1a <alltraps>

80105647 <vector114>:
80105647:	6a 00                	push   $0x0
80105649:	6a 72                	push   $0x72
8010564b:	e9 ca f7 ff ff       	jmp    80104e1a <alltraps>

80105650 <vector115>:
80105650:	6a 00                	push   $0x0
80105652:	6a 73                	push   $0x73
80105654:	e9 c1 f7 ff ff       	jmp    80104e1a <alltraps>

80105659 <vector116>:
80105659:	6a 00                	push   $0x0
8010565b:	6a 74                	push   $0x74
8010565d:	e9 b8 f7 ff ff       	jmp    80104e1a <alltraps>

80105662 <vector117>:
80105662:	6a 00                	push   $0x0
80105664:	6a 75                	push   $0x75
80105666:	e9 af f7 ff ff       	jmp    80104e1a <alltraps>

8010566b <vector118>:
8010566b:	6a 00                	push   $0x0
8010566d:	6a 76                	push   $0x76
8010566f:	e9 a6 f7 ff ff       	jmp    80104e1a <alltraps>

80105674 <vector119>:
80105674:	6a 00                	push   $0x0
80105676:	6a 77                	push   $0x77
80105678:	e9 9d f7 ff ff       	jmp    80104e1a <alltraps>

8010567d <vector120>:
8010567d:	6a 00                	push   $0x0
8010567f:	6a 78                	push   $0x78
80105681:	e9 94 f7 ff ff       	jmp    80104e1a <alltraps>

80105686 <vector121>:
80105686:	6a 00                	push   $0x0
80105688:	6a 79                	push   $0x79
8010568a:	e9 8b f7 ff ff       	jmp    80104e1a <alltraps>

8010568f <vector122>:
8010568f:	6a 00                	push   $0x0
80105691:	6a 7a                	push   $0x7a
80105693:	e9 82 f7 ff ff       	jmp    80104e1a <alltraps>

80105698 <vector123>:
80105698:	6a 00                	push   $0x0
8010569a:	6a 7b                	push   $0x7b
8010569c:	e9 79 f7 ff ff       	jmp    80104e1a <alltraps>

801056a1 <vector124>:
801056a1:	6a 00                	push   $0x0
801056a3:	6a 7c                	push   $0x7c
801056a5:	e9 70 f7 ff ff       	jmp    80104e1a <alltraps>

801056aa <vector125>:
801056aa:	6a 00                	push   $0x0
801056ac:	6a 7d                	push   $0x7d
801056ae:	e9 67 f7 ff ff       	jmp    80104e1a <alltraps>

801056b3 <vector126>:
801056b3:	6a 00                	push   $0x0
801056b5:	6a 7e                	push   $0x7e
801056b7:	e9 5e f7 ff ff       	jmp    80104e1a <alltraps>

801056bc <vector127>:
801056bc:	6a 00                	push   $0x0
801056be:	6a 7f                	push   $0x7f
801056c0:	e9 55 f7 ff ff       	jmp    80104e1a <alltraps>

801056c5 <vector128>:
801056c5:	6a 00                	push   $0x0
801056c7:	68 80 00 00 00       	push   $0x80
801056cc:	e9 49 f7 ff ff       	jmp    80104e1a <alltraps>

801056d1 <vector129>:
801056d1:	6a 00                	push   $0x0
801056d3:	68 81 00 00 00       	push   $0x81
801056d8:	e9 3d f7 ff ff       	jmp    80104e1a <alltraps>

801056dd <vector130>:
801056dd:	6a 00                	push   $0x0
801056df:	68 82 00 00 00       	push   $0x82
801056e4:	e9 31 f7 ff ff       	jmp    80104e1a <alltraps>

801056e9 <vector131>:
801056e9:	6a 00                	push   $0x0
801056eb:	68 83 00 00 00       	push   $0x83
801056f0:	e9 25 f7 ff ff       	jmp    80104e1a <alltraps>

801056f5 <vector132>:
801056f5:	6a 00                	push   $0x0
801056f7:	68 84 00 00 00       	push   $0x84
801056fc:	e9 19 f7 ff ff       	jmp    80104e1a <alltraps>

80105701 <vector133>:
80105701:	6a 00                	push   $0x0
80105703:	68 85 00 00 00       	push   $0x85
80105708:	e9 0d f7 ff ff       	jmp    80104e1a <alltraps>

8010570d <vector134>:
8010570d:	6a 00                	push   $0x0
8010570f:	68 86 00 00 00       	push   $0x86
80105714:	e9 01 f7 ff ff       	jmp    80104e1a <alltraps>

80105719 <vector135>:
80105719:	6a 00                	push   $0x0
8010571b:	68 87 00 00 00       	push   $0x87
80105720:	e9 f5 f6 ff ff       	jmp    80104e1a <alltraps>

80105725 <vector136>:
80105725:	6a 00                	push   $0x0
80105727:	68 88 00 00 00       	push   $0x88
8010572c:	e9 e9 f6 ff ff       	jmp    80104e1a <alltraps>

80105731 <vector137>:
80105731:	6a 00                	push   $0x0
80105733:	68 89 00 00 00       	push   $0x89
80105738:	e9 dd f6 ff ff       	jmp    80104e1a <alltraps>

8010573d <vector138>:
8010573d:	6a 00                	push   $0x0
8010573f:	68 8a 00 00 00       	push   $0x8a
80105744:	e9 d1 f6 ff ff       	jmp    80104e1a <alltraps>

80105749 <vector139>:
80105749:	6a 00                	push   $0x0
8010574b:	68 8b 00 00 00       	push   $0x8b
80105750:	e9 c5 f6 ff ff       	jmp    80104e1a <alltraps>

80105755 <vector140>:
80105755:	6a 00                	push   $0x0
80105757:	68 8c 00 00 00       	push   $0x8c
8010575c:	e9 b9 f6 ff ff       	jmp    80104e1a <alltraps>

80105761 <vector141>:
80105761:	6a 00                	push   $0x0
80105763:	68 8d 00 00 00       	push   $0x8d
80105768:	e9 ad f6 ff ff       	jmp    80104e1a <alltraps>

8010576d <vector142>:
8010576d:	6a 00                	push   $0x0
8010576f:	68 8e 00 00 00       	push   $0x8e
80105774:	e9 a1 f6 ff ff       	jmp    80104e1a <alltraps>

80105779 <vector143>:
80105779:	6a 00                	push   $0x0
8010577b:	68 8f 00 00 00       	push   $0x8f
80105780:	e9 95 f6 ff ff       	jmp    80104e1a <alltraps>

80105785 <vector144>:
80105785:	6a 00                	push   $0x0
80105787:	68 90 00 00 00       	push   $0x90
8010578c:	e9 89 f6 ff ff       	jmp    80104e1a <alltraps>

80105791 <vector145>:
80105791:	6a 00                	push   $0x0
80105793:	68 91 00 00 00       	push   $0x91
80105798:	e9 7d f6 ff ff       	jmp    80104e1a <alltraps>

8010579d <vector146>:
8010579d:	6a 00                	push   $0x0
8010579f:	68 92 00 00 00       	push   $0x92
801057a4:	e9 71 f6 ff ff       	jmp    80104e1a <alltraps>

801057a9 <vector147>:
801057a9:	6a 00                	push   $0x0
801057ab:	68 93 00 00 00       	push   $0x93
801057b0:	e9 65 f6 ff ff       	jmp    80104e1a <alltraps>

801057b5 <vector148>:
801057b5:	6a 00                	push   $0x0
801057b7:	68 94 00 00 00       	push   $0x94
801057bc:	e9 59 f6 ff ff       	jmp    80104e1a <alltraps>

801057c1 <vector149>:
801057c1:	6a 00                	push   $0x0
801057c3:	68 95 00 00 00       	push   $0x95
801057c8:	e9 4d f6 ff ff       	jmp    80104e1a <alltraps>

801057cd <vector150>:
801057cd:	6a 00                	push   $0x0
801057cf:	68 96 00 00 00       	push   $0x96
801057d4:	e9 41 f6 ff ff       	jmp    80104e1a <alltraps>

801057d9 <vector151>:
801057d9:	6a 00                	push   $0x0
801057db:	68 97 00 00 00       	push   $0x97
801057e0:	e9 35 f6 ff ff       	jmp    80104e1a <alltraps>

801057e5 <vector152>:
801057e5:	6a 00                	push   $0x0
801057e7:	68 98 00 00 00       	push   $0x98
801057ec:	e9 29 f6 ff ff       	jmp    80104e1a <alltraps>

801057f1 <vector153>:
801057f1:	6a 00                	push   $0x0
801057f3:	68 99 00 00 00       	push   $0x99
801057f8:	e9 1d f6 ff ff       	jmp    80104e1a <alltraps>

801057fd <vector154>:
801057fd:	6a 00                	push   $0x0
801057ff:	68 9a 00 00 00       	push   $0x9a
80105804:	e9 11 f6 ff ff       	jmp    80104e1a <alltraps>

80105809 <vector155>:
80105809:	6a 00                	push   $0x0
8010580b:	68 9b 00 00 00       	push   $0x9b
80105810:	e9 05 f6 ff ff       	jmp    80104e1a <alltraps>

80105815 <vector156>:
80105815:	6a 00                	push   $0x0
80105817:	68 9c 00 00 00       	push   $0x9c
8010581c:	e9 f9 f5 ff ff       	jmp    80104e1a <alltraps>

80105821 <vector157>:
80105821:	6a 00                	push   $0x0
80105823:	68 9d 00 00 00       	push   $0x9d
80105828:	e9 ed f5 ff ff       	jmp    80104e1a <alltraps>

8010582d <vector158>:
8010582d:	6a 00                	push   $0x0
8010582f:	68 9e 00 00 00       	push   $0x9e
80105834:	e9 e1 f5 ff ff       	jmp    80104e1a <alltraps>

80105839 <vector159>:
80105839:	6a 00                	push   $0x0
8010583b:	68 9f 00 00 00       	push   $0x9f
80105840:	e9 d5 f5 ff ff       	jmp    80104e1a <alltraps>

80105845 <vector160>:
80105845:	6a 00                	push   $0x0
80105847:	68 a0 00 00 00       	push   $0xa0
8010584c:	e9 c9 f5 ff ff       	jmp    80104e1a <alltraps>

80105851 <vector161>:
80105851:	6a 00                	push   $0x0
80105853:	68 a1 00 00 00       	push   $0xa1
80105858:	e9 bd f5 ff ff       	jmp    80104e1a <alltraps>

8010585d <vector162>:
8010585d:	6a 00                	push   $0x0
8010585f:	68 a2 00 00 00       	push   $0xa2
80105864:	e9 b1 f5 ff ff       	jmp    80104e1a <alltraps>

80105869 <vector163>:
80105869:	6a 00                	push   $0x0
8010586b:	68 a3 00 00 00       	push   $0xa3
80105870:	e9 a5 f5 ff ff       	jmp    80104e1a <alltraps>

80105875 <vector164>:
80105875:	6a 00                	push   $0x0
80105877:	68 a4 00 00 00       	push   $0xa4
8010587c:	e9 99 f5 ff ff       	jmp    80104e1a <alltraps>

80105881 <vector165>:
80105881:	6a 00                	push   $0x0
80105883:	68 a5 00 00 00       	push   $0xa5
80105888:	e9 8d f5 ff ff       	jmp    80104e1a <alltraps>

8010588d <vector166>:
8010588d:	6a 00                	push   $0x0
8010588f:	68 a6 00 00 00       	push   $0xa6
80105894:	e9 81 f5 ff ff       	jmp    80104e1a <alltraps>

80105899 <vector167>:
80105899:	6a 00                	push   $0x0
8010589b:	68 a7 00 00 00       	push   $0xa7
801058a0:	e9 75 f5 ff ff       	jmp    80104e1a <alltraps>

801058a5 <vector168>:
801058a5:	6a 00                	push   $0x0
801058a7:	68 a8 00 00 00       	push   $0xa8
801058ac:	e9 69 f5 ff ff       	jmp    80104e1a <alltraps>

801058b1 <vector169>:
801058b1:	6a 00                	push   $0x0
801058b3:	68 a9 00 00 00       	push   $0xa9
801058b8:	e9 5d f5 ff ff       	jmp    80104e1a <alltraps>

801058bd <vector170>:
801058bd:	6a 00                	push   $0x0
801058bf:	68 aa 00 00 00       	push   $0xaa
801058c4:	e9 51 f5 ff ff       	jmp    80104e1a <alltraps>

801058c9 <vector171>:
801058c9:	6a 00                	push   $0x0
801058cb:	68 ab 00 00 00       	push   $0xab
801058d0:	e9 45 f5 ff ff       	jmp    80104e1a <alltraps>

801058d5 <vector172>:
801058d5:	6a 00                	push   $0x0
801058d7:	68 ac 00 00 00       	push   $0xac
801058dc:	e9 39 f5 ff ff       	jmp    80104e1a <alltraps>

801058e1 <vector173>:
801058e1:	6a 00                	push   $0x0
801058e3:	68 ad 00 00 00       	push   $0xad
801058e8:	e9 2d f5 ff ff       	jmp    80104e1a <alltraps>

801058ed <vector174>:
801058ed:	6a 00                	push   $0x0
801058ef:	68 ae 00 00 00       	push   $0xae
801058f4:	e9 21 f5 ff ff       	jmp    80104e1a <alltraps>

801058f9 <vector175>:
801058f9:	6a 00                	push   $0x0
801058fb:	68 af 00 00 00       	push   $0xaf
80105900:	e9 15 f5 ff ff       	jmp    80104e1a <alltraps>

80105905 <vector176>:
80105905:	6a 00                	push   $0x0
80105907:	68 b0 00 00 00       	push   $0xb0
8010590c:	e9 09 f5 ff ff       	jmp    80104e1a <alltraps>

80105911 <vector177>:
80105911:	6a 00                	push   $0x0
80105913:	68 b1 00 00 00       	push   $0xb1
80105918:	e9 fd f4 ff ff       	jmp    80104e1a <alltraps>

8010591d <vector178>:
8010591d:	6a 00                	push   $0x0
8010591f:	68 b2 00 00 00       	push   $0xb2
80105924:	e9 f1 f4 ff ff       	jmp    80104e1a <alltraps>

80105929 <vector179>:
80105929:	6a 00                	push   $0x0
8010592b:	68 b3 00 00 00       	push   $0xb3
80105930:	e9 e5 f4 ff ff       	jmp    80104e1a <alltraps>

80105935 <vector180>:
80105935:	6a 00                	push   $0x0
80105937:	68 b4 00 00 00       	push   $0xb4
8010593c:	e9 d9 f4 ff ff       	jmp    80104e1a <alltraps>

80105941 <vector181>:
80105941:	6a 00                	push   $0x0
80105943:	68 b5 00 00 00       	push   $0xb5
80105948:	e9 cd f4 ff ff       	jmp    80104e1a <alltraps>

8010594d <vector182>:
8010594d:	6a 00                	push   $0x0
8010594f:	68 b6 00 00 00       	push   $0xb6
80105954:	e9 c1 f4 ff ff       	jmp    80104e1a <alltraps>

80105959 <vector183>:
80105959:	6a 00                	push   $0x0
8010595b:	68 b7 00 00 00       	push   $0xb7
80105960:	e9 b5 f4 ff ff       	jmp    80104e1a <alltraps>

80105965 <vector184>:
80105965:	6a 00                	push   $0x0
80105967:	68 b8 00 00 00       	push   $0xb8
8010596c:	e9 a9 f4 ff ff       	jmp    80104e1a <alltraps>

80105971 <vector185>:
80105971:	6a 00                	push   $0x0
80105973:	68 b9 00 00 00       	push   $0xb9
80105978:	e9 9d f4 ff ff       	jmp    80104e1a <alltraps>

8010597d <vector186>:
8010597d:	6a 00                	push   $0x0
8010597f:	68 ba 00 00 00       	push   $0xba
80105984:	e9 91 f4 ff ff       	jmp    80104e1a <alltraps>

80105989 <vector187>:
80105989:	6a 00                	push   $0x0
8010598b:	68 bb 00 00 00       	push   $0xbb
80105990:	e9 85 f4 ff ff       	jmp    80104e1a <alltraps>

80105995 <vector188>:
80105995:	6a 00                	push   $0x0
80105997:	68 bc 00 00 00       	push   $0xbc
8010599c:	e9 79 f4 ff ff       	jmp    80104e1a <alltraps>

801059a1 <vector189>:
801059a1:	6a 00                	push   $0x0
801059a3:	68 bd 00 00 00       	push   $0xbd
801059a8:	e9 6d f4 ff ff       	jmp    80104e1a <alltraps>

801059ad <vector190>:
801059ad:	6a 00                	push   $0x0
801059af:	68 be 00 00 00       	push   $0xbe
801059b4:	e9 61 f4 ff ff       	jmp    80104e1a <alltraps>

801059b9 <vector191>:
801059b9:	6a 00                	push   $0x0
801059bb:	68 bf 00 00 00       	push   $0xbf
801059c0:	e9 55 f4 ff ff       	jmp    80104e1a <alltraps>

801059c5 <vector192>:
801059c5:	6a 00                	push   $0x0
801059c7:	68 c0 00 00 00       	push   $0xc0
801059cc:	e9 49 f4 ff ff       	jmp    80104e1a <alltraps>

801059d1 <vector193>:
801059d1:	6a 00                	push   $0x0
801059d3:	68 c1 00 00 00       	push   $0xc1
801059d8:	e9 3d f4 ff ff       	jmp    80104e1a <alltraps>

801059dd <vector194>:
801059dd:	6a 00                	push   $0x0
801059df:	68 c2 00 00 00       	push   $0xc2
801059e4:	e9 31 f4 ff ff       	jmp    80104e1a <alltraps>

801059e9 <vector195>:
801059e9:	6a 00                	push   $0x0
801059eb:	68 c3 00 00 00       	push   $0xc3
801059f0:	e9 25 f4 ff ff       	jmp    80104e1a <alltraps>

801059f5 <vector196>:
801059f5:	6a 00                	push   $0x0
801059f7:	68 c4 00 00 00       	push   $0xc4
801059fc:	e9 19 f4 ff ff       	jmp    80104e1a <alltraps>

80105a01 <vector197>:
80105a01:	6a 00                	push   $0x0
80105a03:	68 c5 00 00 00       	push   $0xc5
80105a08:	e9 0d f4 ff ff       	jmp    80104e1a <alltraps>

80105a0d <vector198>:
80105a0d:	6a 00                	push   $0x0
80105a0f:	68 c6 00 00 00       	push   $0xc6
80105a14:	e9 01 f4 ff ff       	jmp    80104e1a <alltraps>

80105a19 <vector199>:
80105a19:	6a 00                	push   $0x0
80105a1b:	68 c7 00 00 00       	push   $0xc7
80105a20:	e9 f5 f3 ff ff       	jmp    80104e1a <alltraps>

80105a25 <vector200>:
80105a25:	6a 00                	push   $0x0
80105a27:	68 c8 00 00 00       	push   $0xc8
80105a2c:	e9 e9 f3 ff ff       	jmp    80104e1a <alltraps>

80105a31 <vector201>:
80105a31:	6a 00                	push   $0x0
80105a33:	68 c9 00 00 00       	push   $0xc9
80105a38:	e9 dd f3 ff ff       	jmp    80104e1a <alltraps>

80105a3d <vector202>:
80105a3d:	6a 00                	push   $0x0
80105a3f:	68 ca 00 00 00       	push   $0xca
80105a44:	e9 d1 f3 ff ff       	jmp    80104e1a <alltraps>

80105a49 <vector203>:
80105a49:	6a 00                	push   $0x0
80105a4b:	68 cb 00 00 00       	push   $0xcb
80105a50:	e9 c5 f3 ff ff       	jmp    80104e1a <alltraps>

80105a55 <vector204>:
80105a55:	6a 00                	push   $0x0
80105a57:	68 cc 00 00 00       	push   $0xcc
80105a5c:	e9 b9 f3 ff ff       	jmp    80104e1a <alltraps>

80105a61 <vector205>:
80105a61:	6a 00                	push   $0x0
80105a63:	68 cd 00 00 00       	push   $0xcd
80105a68:	e9 ad f3 ff ff       	jmp    80104e1a <alltraps>

80105a6d <vector206>:
80105a6d:	6a 00                	push   $0x0
80105a6f:	68 ce 00 00 00       	push   $0xce
80105a74:	e9 a1 f3 ff ff       	jmp    80104e1a <alltraps>

80105a79 <vector207>:
80105a79:	6a 00                	push   $0x0
80105a7b:	68 cf 00 00 00       	push   $0xcf
80105a80:	e9 95 f3 ff ff       	jmp    80104e1a <alltraps>

80105a85 <vector208>:
80105a85:	6a 00                	push   $0x0
80105a87:	68 d0 00 00 00       	push   $0xd0
80105a8c:	e9 89 f3 ff ff       	jmp    80104e1a <alltraps>

80105a91 <vector209>:
80105a91:	6a 00                	push   $0x0
80105a93:	68 d1 00 00 00       	push   $0xd1
80105a98:	e9 7d f3 ff ff       	jmp    80104e1a <alltraps>

80105a9d <vector210>:
80105a9d:	6a 00                	push   $0x0
80105a9f:	68 d2 00 00 00       	push   $0xd2
80105aa4:	e9 71 f3 ff ff       	jmp    80104e1a <alltraps>

80105aa9 <vector211>:
80105aa9:	6a 00                	push   $0x0
80105aab:	68 d3 00 00 00       	push   $0xd3
80105ab0:	e9 65 f3 ff ff       	jmp    80104e1a <alltraps>

80105ab5 <vector212>:
80105ab5:	6a 00                	push   $0x0
80105ab7:	68 d4 00 00 00       	push   $0xd4
80105abc:	e9 59 f3 ff ff       	jmp    80104e1a <alltraps>

80105ac1 <vector213>:
80105ac1:	6a 00                	push   $0x0
80105ac3:	68 d5 00 00 00       	push   $0xd5
80105ac8:	e9 4d f3 ff ff       	jmp    80104e1a <alltraps>

80105acd <vector214>:
80105acd:	6a 00                	push   $0x0
80105acf:	68 d6 00 00 00       	push   $0xd6
80105ad4:	e9 41 f3 ff ff       	jmp    80104e1a <alltraps>

80105ad9 <vector215>:
80105ad9:	6a 00                	push   $0x0
80105adb:	68 d7 00 00 00       	push   $0xd7
80105ae0:	e9 35 f3 ff ff       	jmp    80104e1a <alltraps>

80105ae5 <vector216>:
80105ae5:	6a 00                	push   $0x0
80105ae7:	68 d8 00 00 00       	push   $0xd8
80105aec:	e9 29 f3 ff ff       	jmp    80104e1a <alltraps>

80105af1 <vector217>:
80105af1:	6a 00                	push   $0x0
80105af3:	68 d9 00 00 00       	push   $0xd9
80105af8:	e9 1d f3 ff ff       	jmp    80104e1a <alltraps>

80105afd <vector218>:
80105afd:	6a 00                	push   $0x0
80105aff:	68 da 00 00 00       	push   $0xda
80105b04:	e9 11 f3 ff ff       	jmp    80104e1a <alltraps>

80105b09 <vector219>:
80105b09:	6a 00                	push   $0x0
80105b0b:	68 db 00 00 00       	push   $0xdb
80105b10:	e9 05 f3 ff ff       	jmp    80104e1a <alltraps>

80105b15 <vector220>:
80105b15:	6a 00                	push   $0x0
80105b17:	68 dc 00 00 00       	push   $0xdc
80105b1c:	e9 f9 f2 ff ff       	jmp    80104e1a <alltraps>

80105b21 <vector221>:
80105b21:	6a 00                	push   $0x0
80105b23:	68 dd 00 00 00       	push   $0xdd
80105b28:	e9 ed f2 ff ff       	jmp    80104e1a <alltraps>

80105b2d <vector222>:
80105b2d:	6a 00                	push   $0x0
80105b2f:	68 de 00 00 00       	push   $0xde
80105b34:	e9 e1 f2 ff ff       	jmp    80104e1a <alltraps>

80105b39 <vector223>:
80105b39:	6a 00                	push   $0x0
80105b3b:	68 df 00 00 00       	push   $0xdf
80105b40:	e9 d5 f2 ff ff       	jmp    80104e1a <alltraps>

80105b45 <vector224>:
80105b45:	6a 00                	push   $0x0
80105b47:	68 e0 00 00 00       	push   $0xe0
80105b4c:	e9 c9 f2 ff ff       	jmp    80104e1a <alltraps>

80105b51 <vector225>:
80105b51:	6a 00                	push   $0x0
80105b53:	68 e1 00 00 00       	push   $0xe1
80105b58:	e9 bd f2 ff ff       	jmp    80104e1a <alltraps>

80105b5d <vector226>:
80105b5d:	6a 00                	push   $0x0
80105b5f:	68 e2 00 00 00       	push   $0xe2
80105b64:	e9 b1 f2 ff ff       	jmp    80104e1a <alltraps>

80105b69 <vector227>:
80105b69:	6a 00                	push   $0x0
80105b6b:	68 e3 00 00 00       	push   $0xe3
80105b70:	e9 a5 f2 ff ff       	jmp    80104e1a <alltraps>

80105b75 <vector228>:
80105b75:	6a 00                	push   $0x0
80105b77:	68 e4 00 00 00       	push   $0xe4
80105b7c:	e9 99 f2 ff ff       	jmp    80104e1a <alltraps>

80105b81 <vector229>:
80105b81:	6a 00                	push   $0x0
80105b83:	68 e5 00 00 00       	push   $0xe5
80105b88:	e9 8d f2 ff ff       	jmp    80104e1a <alltraps>

80105b8d <vector230>:
80105b8d:	6a 00                	push   $0x0
80105b8f:	68 e6 00 00 00       	push   $0xe6
80105b94:	e9 81 f2 ff ff       	jmp    80104e1a <alltraps>

80105b99 <vector231>:
80105b99:	6a 00                	push   $0x0
80105b9b:	68 e7 00 00 00       	push   $0xe7
80105ba0:	e9 75 f2 ff ff       	jmp    80104e1a <alltraps>

80105ba5 <vector232>:
80105ba5:	6a 00                	push   $0x0
80105ba7:	68 e8 00 00 00       	push   $0xe8
80105bac:	e9 69 f2 ff ff       	jmp    80104e1a <alltraps>

80105bb1 <vector233>:
80105bb1:	6a 00                	push   $0x0
80105bb3:	68 e9 00 00 00       	push   $0xe9
80105bb8:	e9 5d f2 ff ff       	jmp    80104e1a <alltraps>

80105bbd <vector234>:
80105bbd:	6a 00                	push   $0x0
80105bbf:	68 ea 00 00 00       	push   $0xea
80105bc4:	e9 51 f2 ff ff       	jmp    80104e1a <alltraps>

80105bc9 <vector235>:
80105bc9:	6a 00                	push   $0x0
80105bcb:	68 eb 00 00 00       	push   $0xeb
80105bd0:	e9 45 f2 ff ff       	jmp    80104e1a <alltraps>

80105bd5 <vector236>:
80105bd5:	6a 00                	push   $0x0
80105bd7:	68 ec 00 00 00       	push   $0xec
80105bdc:	e9 39 f2 ff ff       	jmp    80104e1a <alltraps>

80105be1 <vector237>:
80105be1:	6a 00                	push   $0x0
80105be3:	68 ed 00 00 00       	push   $0xed
80105be8:	e9 2d f2 ff ff       	jmp    80104e1a <alltraps>

80105bed <vector238>:
80105bed:	6a 00                	push   $0x0
80105bef:	68 ee 00 00 00       	push   $0xee
80105bf4:	e9 21 f2 ff ff       	jmp    80104e1a <alltraps>

80105bf9 <vector239>:
80105bf9:	6a 00                	push   $0x0
80105bfb:	68 ef 00 00 00       	push   $0xef
80105c00:	e9 15 f2 ff ff       	jmp    80104e1a <alltraps>

80105c05 <vector240>:
80105c05:	6a 00                	push   $0x0
80105c07:	68 f0 00 00 00       	push   $0xf0
80105c0c:	e9 09 f2 ff ff       	jmp    80104e1a <alltraps>

80105c11 <vector241>:
80105c11:	6a 00                	push   $0x0
80105c13:	68 f1 00 00 00       	push   $0xf1
80105c18:	e9 fd f1 ff ff       	jmp    80104e1a <alltraps>

80105c1d <vector242>:
80105c1d:	6a 00                	push   $0x0
80105c1f:	68 f2 00 00 00       	push   $0xf2
80105c24:	e9 f1 f1 ff ff       	jmp    80104e1a <alltraps>

80105c29 <vector243>:
80105c29:	6a 00                	push   $0x0
80105c2b:	68 f3 00 00 00       	push   $0xf3
80105c30:	e9 e5 f1 ff ff       	jmp    80104e1a <alltraps>

80105c35 <vector244>:
80105c35:	6a 00                	push   $0x0
80105c37:	68 f4 00 00 00       	push   $0xf4
80105c3c:	e9 d9 f1 ff ff       	jmp    80104e1a <alltraps>

80105c41 <vector245>:
80105c41:	6a 00                	push   $0x0
80105c43:	68 f5 00 00 00       	push   $0xf5
80105c48:	e9 cd f1 ff ff       	jmp    80104e1a <alltraps>

80105c4d <vector246>:
80105c4d:	6a 00                	push   $0x0
80105c4f:	68 f6 00 00 00       	push   $0xf6
80105c54:	e9 c1 f1 ff ff       	jmp    80104e1a <alltraps>

80105c59 <vector247>:
80105c59:	6a 00                	push   $0x0
80105c5b:	68 f7 00 00 00       	push   $0xf7
80105c60:	e9 b5 f1 ff ff       	jmp    80104e1a <alltraps>

80105c65 <vector248>:
80105c65:	6a 00                	push   $0x0
80105c67:	68 f8 00 00 00       	push   $0xf8
80105c6c:	e9 a9 f1 ff ff       	jmp    80104e1a <alltraps>

80105c71 <vector249>:
80105c71:	6a 00                	push   $0x0
80105c73:	68 f9 00 00 00       	push   $0xf9
80105c78:	e9 9d f1 ff ff       	jmp    80104e1a <alltraps>

80105c7d <vector250>:
80105c7d:	6a 00                	push   $0x0
80105c7f:	68 fa 00 00 00       	push   $0xfa
80105c84:	e9 91 f1 ff ff       	jmp    80104e1a <alltraps>

80105c89 <vector251>:
80105c89:	6a 00                	push   $0x0
80105c8b:	68 fb 00 00 00       	push   $0xfb
80105c90:	e9 85 f1 ff ff       	jmp    80104e1a <alltraps>

80105c95 <vector252>:
80105c95:	6a 00                	push   $0x0
80105c97:	68 fc 00 00 00       	push   $0xfc
80105c9c:	e9 79 f1 ff ff       	jmp    80104e1a <alltraps>

80105ca1 <vector253>:
80105ca1:	6a 00                	push   $0x0
80105ca3:	68 fd 00 00 00       	push   $0xfd
80105ca8:	e9 6d f1 ff ff       	jmp    80104e1a <alltraps>

80105cad <vector254>:
80105cad:	6a 00                	push   $0x0
80105caf:	68 fe 00 00 00       	push   $0xfe
80105cb4:	e9 61 f1 ff ff       	jmp    80104e1a <alltraps>

80105cb9 <vector255>:
80105cb9:	6a 00                	push   $0x0
80105cbb:	68 ff 00 00 00       	push   $0xff
80105cc0:	e9 55 f1 ff ff       	jmp    80104e1a <alltraps>

80105cc5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105cc5:	55                   	push   %ebp
80105cc6:	89 e5                	mov    %esp,%ebp
80105cc8:	57                   	push   %edi
80105cc9:	56                   	push   %esi
80105cca:	53                   	push   %ebx
80105ccb:	83 ec 0c             	sub    $0xc,%esp
80105cce:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105cd0:	c1 ea 16             	shr    $0x16,%edx
80105cd3:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105cd6:	8b 1f                	mov    (%edi),%ebx
80105cd8:	f6 c3 01             	test   $0x1,%bl
80105cdb:	74 22                	je     80105cff <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105cdd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105ce3:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105ce9:	c1 ee 0c             	shr    $0xc,%esi
80105cec:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105cf2:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105cf5:	89 d8                	mov    %ebx,%eax
80105cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105cfa:	5b                   	pop    %ebx
80105cfb:	5e                   	pop    %esi
80105cfc:	5f                   	pop    %edi
80105cfd:	5d                   	pop    %ebp
80105cfe:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc(-2)) == 0)
80105cff:	85 c9                	test   %ecx,%ecx
80105d01:	74 33                	je     80105d36 <walkpgdir+0x71>
80105d03:	83 ec 0c             	sub    $0xc,%esp
80105d06:	6a fe                	push   $0xfffffffe
80105d08:	e8 ba c3 ff ff       	call   801020c7 <kalloc>
80105d0d:	89 c3                	mov    %eax,%ebx
80105d0f:	83 c4 10             	add    $0x10,%esp
80105d12:	85 c0                	test   %eax,%eax
80105d14:	74 df                	je     80105cf5 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105d16:	83 ec 04             	sub    $0x4,%esp
80105d19:	68 00 10 00 00       	push   $0x1000
80105d1e:	6a 00                	push   $0x0
80105d20:	50                   	push   %eax
80105d21:	e8 f6 df ff ff       	call   80103d1c <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105d26:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105d2c:	83 c8 07             	or     $0x7,%eax
80105d2f:	89 07                	mov    %eax,(%edi)
80105d31:	83 c4 10             	add    $0x10,%esp
80105d34:	eb b3                	jmp    80105ce9 <walkpgdir+0x24>
      return 0;
80105d36:	bb 00 00 00 00       	mov    $0x0,%ebx
80105d3b:	eb b8                	jmp    80105cf5 <walkpgdir+0x30>

80105d3d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105d3d:	55                   	push   %ebp
80105d3e:	89 e5                	mov    %esp,%ebp
80105d40:	57                   	push   %edi
80105d41:	56                   	push   %esi
80105d42:	53                   	push   %ebx
80105d43:	83 ec 1c             	sub    $0x1c,%esp
80105d46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105d49:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105d4c:	89 d3                	mov    %edx,%ebx
80105d4e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105d54:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105d58:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d5e:	b9 01 00 00 00       	mov    $0x1,%ecx
80105d63:	89 da                	mov    %ebx,%edx
80105d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d68:	e8 58 ff ff ff       	call   80105cc5 <walkpgdir>
80105d6d:	85 c0                	test   %eax,%eax
80105d6f:	74 2e                	je     80105d9f <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105d71:	f6 00 01             	testb  $0x1,(%eax)
80105d74:	75 1c                	jne    80105d92 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105d76:	89 f2                	mov    %esi,%edx
80105d78:	0b 55 0c             	or     0xc(%ebp),%edx
80105d7b:	83 ca 01             	or     $0x1,%edx
80105d7e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d80:	39 fb                	cmp    %edi,%ebx
80105d82:	74 28                	je     80105dac <mappages+0x6f>
      break;
    a += PGSIZE;
80105d84:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d8a:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d90:	eb cc                	jmp    80105d5e <mappages+0x21>
      panic("remap");
80105d92:	83 ec 0c             	sub    $0xc,%esp
80105d95:	68 6c 6e 10 80       	push   $0x80106e6c
80105d9a:	e8 a9 a5 ff ff       	call   80100348 <panic>
      return -1;
80105d9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105da7:	5b                   	pop    %ebx
80105da8:	5e                   	pop    %esi
80105da9:	5f                   	pop    %edi
80105daa:	5d                   	pop    %ebp
80105dab:	c3                   	ret    
  return 0;
80105dac:	b8 00 00 00 00       	mov    $0x0,%eax
80105db1:	eb f1                	jmp    80105da4 <mappages+0x67>

80105db3 <seginit>:
{
80105db3:	55                   	push   %ebp
80105db4:	89 e5                	mov    %esp,%ebp
80105db6:	53                   	push   %ebx
80105db7:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105dba:	e8 f4 d4 ff ff       	call   801032b3 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105dbf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105dc5:	66 c7 80 18 18 13 80 	movw   $0xffff,-0x7fece7e8(%eax)
80105dcc:	ff ff 
80105dce:	66 c7 80 1a 18 13 80 	movw   $0x0,-0x7fece7e6(%eax)
80105dd5:	00 00 
80105dd7:	c6 80 1c 18 13 80 00 	movb   $0x0,-0x7fece7e4(%eax)
80105dde:	0f b6 88 1d 18 13 80 	movzbl -0x7fece7e3(%eax),%ecx
80105de5:	83 e1 f0             	and    $0xfffffff0,%ecx
80105de8:	83 c9 1a             	or     $0x1a,%ecx
80105deb:	83 e1 9f             	and    $0xffffff9f,%ecx
80105dee:	83 c9 80             	or     $0xffffff80,%ecx
80105df1:	88 88 1d 18 13 80    	mov    %cl,-0x7fece7e3(%eax)
80105df7:	0f b6 88 1e 18 13 80 	movzbl -0x7fece7e2(%eax),%ecx
80105dfe:	83 c9 0f             	or     $0xf,%ecx
80105e01:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e04:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e07:	88 88 1e 18 13 80    	mov    %cl,-0x7fece7e2(%eax)
80105e0d:	c6 80 1f 18 13 80 00 	movb   $0x0,-0x7fece7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105e14:	66 c7 80 20 18 13 80 	movw   $0xffff,-0x7fece7e0(%eax)
80105e1b:	ff ff 
80105e1d:	66 c7 80 22 18 13 80 	movw   $0x0,-0x7fece7de(%eax)
80105e24:	00 00 
80105e26:	c6 80 24 18 13 80 00 	movb   $0x0,-0x7fece7dc(%eax)
80105e2d:	0f b6 88 25 18 13 80 	movzbl -0x7fece7db(%eax),%ecx
80105e34:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e37:	83 c9 12             	or     $0x12,%ecx
80105e3a:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e3d:	83 c9 80             	or     $0xffffff80,%ecx
80105e40:	88 88 25 18 13 80    	mov    %cl,-0x7fece7db(%eax)
80105e46:	0f b6 88 26 18 13 80 	movzbl -0x7fece7da(%eax),%ecx
80105e4d:	83 c9 0f             	or     $0xf,%ecx
80105e50:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e53:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e56:	88 88 26 18 13 80    	mov    %cl,-0x7fece7da(%eax)
80105e5c:	c6 80 27 18 13 80 00 	movb   $0x0,-0x7fece7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105e63:	66 c7 80 28 18 13 80 	movw   $0xffff,-0x7fece7d8(%eax)
80105e6a:	ff ff 
80105e6c:	66 c7 80 2a 18 13 80 	movw   $0x0,-0x7fece7d6(%eax)
80105e73:	00 00 
80105e75:	c6 80 2c 18 13 80 00 	movb   $0x0,-0x7fece7d4(%eax)
80105e7c:	c6 80 2d 18 13 80 fa 	movb   $0xfa,-0x7fece7d3(%eax)
80105e83:	0f b6 88 2e 18 13 80 	movzbl -0x7fece7d2(%eax),%ecx
80105e8a:	83 c9 0f             	or     $0xf,%ecx
80105e8d:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e90:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e93:	88 88 2e 18 13 80    	mov    %cl,-0x7fece7d2(%eax)
80105e99:	c6 80 2f 18 13 80 00 	movb   $0x0,-0x7fece7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105ea0:	66 c7 80 30 18 13 80 	movw   $0xffff,-0x7fece7d0(%eax)
80105ea7:	ff ff 
80105ea9:	66 c7 80 32 18 13 80 	movw   $0x0,-0x7fece7ce(%eax)
80105eb0:	00 00 
80105eb2:	c6 80 34 18 13 80 00 	movb   $0x0,-0x7fece7cc(%eax)
80105eb9:	c6 80 35 18 13 80 f2 	movb   $0xf2,-0x7fece7cb(%eax)
80105ec0:	0f b6 88 36 18 13 80 	movzbl -0x7fece7ca(%eax),%ecx
80105ec7:	83 c9 0f             	or     $0xf,%ecx
80105eca:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ecd:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ed0:	88 88 36 18 13 80    	mov    %cl,-0x7fece7ca(%eax)
80105ed6:	c6 80 37 18 13 80 00 	movb   $0x0,-0x7fece7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105edd:	05 10 18 13 80       	add    $0x80131810,%eax
  pd[0] = size-1;
80105ee2:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105ee8:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105eec:	c1 e8 10             	shr    $0x10,%eax
80105eef:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105ef3:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105ef6:	0f 01 10             	lgdtl  (%eax)
}
80105ef9:	83 c4 14             	add    $0x14,%esp
80105efc:	5b                   	pop    %ebx
80105efd:	5d                   	pop    %ebp
80105efe:	c3                   	ret    

80105eff <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105eff:	55                   	push   %ebp
80105f00:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105f02:	a1 c4 44 13 80       	mov    0x801344c4,%eax
80105f07:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f0c:	0f 22 d8             	mov    %eax,%cr3
}
80105f0f:	5d                   	pop    %ebp
80105f10:	c3                   	ret    

80105f11 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105f11:	55                   	push   %ebp
80105f12:	89 e5                	mov    %esp,%ebp
80105f14:	57                   	push   %edi
80105f15:	56                   	push   %esi
80105f16:	53                   	push   %ebx
80105f17:	83 ec 1c             	sub    $0x1c,%esp
80105f1a:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105f1d:	85 f6                	test   %esi,%esi
80105f1f:	0f 84 dd 00 00 00    	je     80106002 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105f25:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105f29:	0f 84 e0 00 00 00    	je     8010600f <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105f2f:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105f33:	0f 84 e3 00 00 00    	je     8010601c <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105f39:	e8 55 dc ff ff       	call   80103b93 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105f3e:	e8 14 d3 ff ff       	call   80103257 <mycpu>
80105f43:	89 c3                	mov    %eax,%ebx
80105f45:	e8 0d d3 ff ff       	call   80103257 <mycpu>
80105f4a:	8d 78 08             	lea    0x8(%eax),%edi
80105f4d:	e8 05 d3 ff ff       	call   80103257 <mycpu>
80105f52:	83 c0 08             	add    $0x8,%eax
80105f55:	c1 e8 10             	shr    $0x10,%eax
80105f58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f5b:	e8 f7 d2 ff ff       	call   80103257 <mycpu>
80105f60:	83 c0 08             	add    $0x8,%eax
80105f63:	c1 e8 18             	shr    $0x18,%eax
80105f66:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105f6d:	67 00 
80105f6f:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105f76:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105f7a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105f80:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105f87:	83 e2 f0             	and    $0xfffffff0,%edx
80105f8a:	83 ca 19             	or     $0x19,%edx
80105f8d:	83 e2 9f             	and    $0xffffff9f,%edx
80105f90:	83 ca 80             	or     $0xffffff80,%edx
80105f93:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105f99:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105fa0:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105fa6:	e8 ac d2 ff ff       	call   80103257 <mycpu>
80105fab:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105fb2:	83 e2 ef             	and    $0xffffffef,%edx
80105fb5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105fbb:	e8 97 d2 ff ff       	call   80103257 <mycpu>
80105fc0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105fc6:	8b 5e 08             	mov    0x8(%esi),%ebx
80105fc9:	e8 89 d2 ff ff       	call   80103257 <mycpu>
80105fce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105fd4:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105fd7:	e8 7b d2 ff ff       	call   80103257 <mycpu>
80105fdc:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105fe2:	b8 28 00 00 00       	mov    $0x28,%eax
80105fe7:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105fea:	8b 46 04             	mov    0x4(%esi),%eax
80105fed:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105ff2:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105ff5:	e8 d6 db ff ff       	call   80103bd0 <popcli>
}
80105ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ffd:	5b                   	pop    %ebx
80105ffe:	5e                   	pop    %esi
80105fff:	5f                   	pop    %edi
80106000:	5d                   	pop    %ebp
80106001:	c3                   	ret    
    panic("switchuvm: no process");
80106002:	83 ec 0c             	sub    $0xc,%esp
80106005:	68 72 6e 10 80       	push   $0x80106e72
8010600a:	e8 39 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010600f:	83 ec 0c             	sub    $0xc,%esp
80106012:	68 88 6e 10 80       	push   $0x80106e88
80106017:	e8 2c a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
8010601c:	83 ec 0c             	sub    $0xc,%esp
8010601f:	68 9d 6e 10 80       	push   $0x80106e9d
80106024:	e8 1f a3 ff ff       	call   80100348 <panic>

80106029 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106029:	55                   	push   %ebp
8010602a:	89 e5                	mov    %esp,%ebp
8010602c:	56                   	push   %esi
8010602d:	53                   	push   %ebx
8010602e:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106031:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106037:	77 51                	ja     8010608a <inituvm+0x61>
    panic("inituvm: more than a page");
  mem = kalloc(-2);
80106039:	83 ec 0c             	sub    $0xc,%esp
8010603c:	6a fe                	push   $0xfffffffe
8010603e:	e8 84 c0 ff ff       	call   801020c7 <kalloc>
80106043:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106045:	83 c4 0c             	add    $0xc,%esp
80106048:	68 00 10 00 00       	push   $0x1000
8010604d:	6a 00                	push   $0x0
8010604f:	50                   	push   %eax
80106050:	e8 c7 dc ff ff       	call   80103d1c <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106055:	83 c4 08             	add    $0x8,%esp
80106058:	6a 06                	push   $0x6
8010605a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106060:	50                   	push   %eax
80106061:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106066:	ba 00 00 00 00       	mov    $0x0,%edx
8010606b:	8b 45 08             	mov    0x8(%ebp),%eax
8010606e:	e8 ca fc ff ff       	call   80105d3d <mappages>
  memmove(mem, init, sz);
80106073:	83 c4 0c             	add    $0xc,%esp
80106076:	56                   	push   %esi
80106077:	ff 75 0c             	pushl  0xc(%ebp)
8010607a:	53                   	push   %ebx
8010607b:	e8 17 dd ff ff       	call   80103d97 <memmove>
}
80106080:	83 c4 10             	add    $0x10,%esp
80106083:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106086:	5b                   	pop    %ebx
80106087:	5e                   	pop    %esi
80106088:	5d                   	pop    %ebp
80106089:	c3                   	ret    
    panic("inituvm: more than a page");
8010608a:	83 ec 0c             	sub    $0xc,%esp
8010608d:	68 b1 6e 10 80       	push   $0x80106eb1
80106092:	e8 b1 a2 ff ff       	call   80100348 <panic>

80106097 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106097:	55                   	push   %ebp
80106098:	89 e5                	mov    %esp,%ebp
8010609a:	57                   	push   %edi
8010609b:	56                   	push   %esi
8010609c:	53                   	push   %ebx
8010609d:	83 ec 0c             	sub    $0xc,%esp
801060a0:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801060a3:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801060aa:	75 07                	jne    801060b3 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801060ac:	bb 00 00 00 00       	mov    $0x0,%ebx
801060b1:	eb 3c                	jmp    801060ef <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
801060b3:	83 ec 0c             	sub    $0xc,%esp
801060b6:	68 6c 6f 10 80       	push   $0x80106f6c
801060bb:	e8 88 a2 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801060c0:	83 ec 0c             	sub    $0xc,%esp
801060c3:	68 cb 6e 10 80       	push   $0x80106ecb
801060c8:	e8 7b a2 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801060cd:	05 00 00 00 80       	add    $0x80000000,%eax
801060d2:	56                   	push   %esi
801060d3:	89 da                	mov    %ebx,%edx
801060d5:	03 55 14             	add    0x14(%ebp),%edx
801060d8:	52                   	push   %edx
801060d9:	50                   	push   %eax
801060da:	ff 75 10             	pushl  0x10(%ebp)
801060dd:	e8 9d b6 ff ff       	call   8010177f <readi>
801060e2:	83 c4 10             	add    $0x10,%esp
801060e5:	39 f0                	cmp    %esi,%eax
801060e7:	75 47                	jne    80106130 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801060e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060ef:	39 fb                	cmp    %edi,%ebx
801060f1:	73 30                	jae    80106123 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801060f3:	89 da                	mov    %ebx,%edx
801060f5:	03 55 0c             	add    0xc(%ebp),%edx
801060f8:	b9 00 00 00 00       	mov    $0x0,%ecx
801060fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106100:	e8 c0 fb ff ff       	call   80105cc5 <walkpgdir>
80106105:	85 c0                	test   %eax,%eax
80106107:	74 b7                	je     801060c0 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
80106109:	8b 00                	mov    (%eax),%eax
8010610b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106110:	89 fe                	mov    %edi,%esi
80106112:	29 de                	sub    %ebx,%esi
80106114:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010611a:	76 b1                	jbe    801060cd <loaduvm+0x36>
      n = PGSIZE;
8010611c:	be 00 10 00 00       	mov    $0x1000,%esi
80106121:	eb aa                	jmp    801060cd <loaduvm+0x36>
      return -1;
  }
  return 0;
80106123:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106128:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010612b:	5b                   	pop    %ebx
8010612c:	5e                   	pop    %esi
8010612d:	5f                   	pop    %edi
8010612e:	5d                   	pop    %ebp
8010612f:	c3                   	ret    
      return -1;
80106130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106135:	eb f1                	jmp    80106128 <loaduvm+0x91>

80106137 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106137:	55                   	push   %ebp
80106138:	89 e5                	mov    %esp,%ebp
8010613a:	57                   	push   %edi
8010613b:	56                   	push   %esi
8010613c:	53                   	push   %ebx
8010613d:	83 ec 0c             	sub    $0xc,%esp
80106140:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106143:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106146:	73 11                	jae    80106159 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106148:	8b 45 10             	mov    0x10(%ebp),%eax
8010614b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106151:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106157:	eb 19                	jmp    80106172 <deallocuvm+0x3b>
    return oldsz;
80106159:	89 f8                	mov    %edi,%eax
8010615b:	eb 64                	jmp    801061c1 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010615d:	c1 eb 16             	shr    $0x16,%ebx
80106160:	83 c3 01             	add    $0x1,%ebx
80106163:	c1 e3 16             	shl    $0x16,%ebx
80106166:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010616c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106172:	39 fb                	cmp    %edi,%ebx
80106174:	73 48                	jae    801061be <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106176:	b9 00 00 00 00       	mov    $0x0,%ecx
8010617b:	89 da                	mov    %ebx,%edx
8010617d:	8b 45 08             	mov    0x8(%ebp),%eax
80106180:	e8 40 fb ff ff       	call   80105cc5 <walkpgdir>
80106185:	89 c6                	mov    %eax,%esi
    if(!pte)
80106187:	85 c0                	test   %eax,%eax
80106189:	74 d2                	je     8010615d <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010618b:	8b 00                	mov    (%eax),%eax
8010618d:	a8 01                	test   $0x1,%al
8010618f:	74 db                	je     8010616c <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106191:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106196:	74 19                	je     801061b1 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106198:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010619d:	83 ec 0c             	sub    $0xc,%esp
801061a0:	50                   	push   %eax
801061a1:	e8 0a be ff ff       	call   80101fb0 <kfree>
      *pte = 0;
801061a6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801061ac:	83 c4 10             	add    $0x10,%esp
801061af:	eb bb                	jmp    8010616c <deallocuvm+0x35>
        panic("kfree");
801061b1:	83 ec 0c             	sub    $0xc,%esp
801061b4:	68 06 68 10 80       	push   $0x80106806
801061b9:	e8 8a a1 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801061be:	8b 45 10             	mov    0x10(%ebp),%eax
}
801061c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061c4:	5b                   	pop    %ebx
801061c5:	5e                   	pop    %esi
801061c6:	5f                   	pop    %edi
801061c7:	5d                   	pop    %ebp
801061c8:	c3                   	ret    

801061c9 <allocuvm>:
{
801061c9:	55                   	push   %ebp
801061ca:	89 e5                	mov    %esp,%ebp
801061cc:	57                   	push   %edi
801061cd:	56                   	push   %esi
801061ce:	53                   	push   %ebx
801061cf:	83 ec 1c             	sub    $0x1c,%esp
801061d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801061d5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801061d8:	85 ff                	test   %edi,%edi
801061da:	0f 88 ca 00 00 00    	js     801062aa <allocuvm+0xe1>
  if(newsz < oldsz)
801061e0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801061e3:	72 65                	jb     8010624a <allocuvm+0x81>
  a = PGROUNDUP(oldsz);
801061e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801061e8:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801061ee:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801061f4:	39 fb                	cmp    %edi,%ebx
801061f6:	0f 83 b5 00 00 00    	jae    801062b1 <allocuvm+0xe8>
    mem = kalloc(pid);
801061fc:	83 ec 0c             	sub    $0xc,%esp
801061ff:	ff 75 14             	pushl  0x14(%ebp)
80106202:	e8 c0 be ff ff       	call   801020c7 <kalloc>
80106207:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106209:	83 c4 10             	add    $0x10,%esp
8010620c:	85 c0                	test   %eax,%eax
8010620e:	74 42                	je     80106252 <allocuvm+0x89>
    memset(mem, 0, PGSIZE);
80106210:	83 ec 04             	sub    $0x4,%esp
80106213:	68 00 10 00 00       	push   $0x1000
80106218:	6a 00                	push   $0x0
8010621a:	50                   	push   %eax
8010621b:	e8 fc da ff ff       	call   80103d1c <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106220:	83 c4 08             	add    $0x8,%esp
80106223:	6a 06                	push   $0x6
80106225:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
8010622b:	50                   	push   %eax
8010622c:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106231:	89 da                	mov    %ebx,%edx
80106233:	8b 45 08             	mov    0x8(%ebp),%eax
80106236:	e8 02 fb ff ff       	call   80105d3d <mappages>
8010623b:	83 c4 10             	add    $0x10,%esp
8010623e:	85 c0                	test   %eax,%eax
80106240:	78 38                	js     8010627a <allocuvm+0xb1>
  for(; a < newsz; a += PGSIZE){
80106242:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106248:	eb aa                	jmp    801061f4 <allocuvm+0x2b>
    return oldsz;
8010624a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010624d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106250:	eb 5f                	jmp    801062b1 <allocuvm+0xe8>
      cprintf("allocuvm out of memory\n");
80106252:	83 ec 0c             	sub    $0xc,%esp
80106255:	68 e9 6e 10 80       	push   $0x80106ee9
8010625a:	e8 ac a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010625f:	83 c4 0c             	add    $0xc,%esp
80106262:	ff 75 0c             	pushl  0xc(%ebp)
80106265:	57                   	push   %edi
80106266:	ff 75 08             	pushl  0x8(%ebp)
80106269:	e8 c9 fe ff ff       	call   80106137 <deallocuvm>
      return 0;
8010626e:	83 c4 10             	add    $0x10,%esp
80106271:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106278:	eb 37                	jmp    801062b1 <allocuvm+0xe8>
      cprintf("allocuvm out of memory (2)\n");
8010627a:	83 ec 0c             	sub    $0xc,%esp
8010627d:	68 01 6f 10 80       	push   $0x80106f01
80106282:	e8 84 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106287:	83 c4 0c             	add    $0xc,%esp
8010628a:	ff 75 0c             	pushl  0xc(%ebp)
8010628d:	57                   	push   %edi
8010628e:	ff 75 08             	pushl  0x8(%ebp)
80106291:	e8 a1 fe ff ff       	call   80106137 <deallocuvm>
      kfree(mem);
80106296:	89 34 24             	mov    %esi,(%esp)
80106299:	e8 12 bd ff ff       	call   80101fb0 <kfree>
      return 0;
8010629e:	83 c4 10             	add    $0x10,%esp
801062a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801062a8:	eb 07                	jmp    801062b1 <allocuvm+0xe8>
    return 0;
801062aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801062b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062b7:	5b                   	pop    %ebx
801062b8:	5e                   	pop    %esi
801062b9:	5f                   	pop    %edi
801062ba:	5d                   	pop    %ebp
801062bb:	c3                   	ret    

801062bc <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801062bc:	55                   	push   %ebp
801062bd:	89 e5                	mov    %esp,%ebp
801062bf:	56                   	push   %esi
801062c0:	53                   	push   %ebx
801062c1:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801062c4:	85 f6                	test   %esi,%esi
801062c6:	74 1a                	je     801062e2 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801062c8:	83 ec 04             	sub    $0x4,%esp
801062cb:	6a 00                	push   $0x0
801062cd:	68 00 00 00 80       	push   $0x80000000
801062d2:	56                   	push   %esi
801062d3:	e8 5f fe ff ff       	call   80106137 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801062d8:	83 c4 10             	add    $0x10,%esp
801062db:	bb 00 00 00 00       	mov    $0x0,%ebx
801062e0:	eb 10                	jmp    801062f2 <freevm+0x36>
    panic("freevm: no pgdir");
801062e2:	83 ec 0c             	sub    $0xc,%esp
801062e5:	68 1d 6f 10 80       	push   $0x80106f1d
801062ea:	e8 59 a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801062ef:	83 c3 01             	add    $0x1,%ebx
801062f2:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801062f8:	77 1f                	ja     80106319 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801062fa:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801062fd:	a8 01                	test   $0x1,%al
801062ff:	74 ee                	je     801062ef <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106301:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106306:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010630b:	83 ec 0c             	sub    $0xc,%esp
8010630e:	50                   	push   %eax
8010630f:	e8 9c bc ff ff       	call   80101fb0 <kfree>
80106314:	83 c4 10             	add    $0x10,%esp
80106317:	eb d6                	jmp    801062ef <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106319:	83 ec 0c             	sub    $0xc,%esp
8010631c:	56                   	push   %esi
8010631d:	e8 8e bc ff ff       	call   80101fb0 <kfree>
}
80106322:	83 c4 10             	add    $0x10,%esp
80106325:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106328:	5b                   	pop    %ebx
80106329:	5e                   	pop    %esi
8010632a:	5d                   	pop    %ebp
8010632b:	c3                   	ret    

8010632c <setupkvm>:
{
8010632c:	55                   	push   %ebp
8010632d:	89 e5                	mov    %esp,%ebp
8010632f:	56                   	push   %esi
80106330:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc(-2)) == 0)
80106331:	83 ec 0c             	sub    $0xc,%esp
80106334:	6a fe                	push   $0xfffffffe
80106336:	e8 8c bd ff ff       	call   801020c7 <kalloc>
8010633b:	89 c6                	mov    %eax,%esi
8010633d:	83 c4 10             	add    $0x10,%esp
80106340:	85 c0                	test   %eax,%eax
80106342:	74 55                	je     80106399 <setupkvm+0x6d>
  memset(pgdir, 0, PGSIZE);
80106344:	83 ec 04             	sub    $0x4,%esp
80106347:	68 00 10 00 00       	push   $0x1000
8010634c:	6a 00                	push   $0x0
8010634e:	50                   	push   %eax
8010634f:	e8 c8 d9 ff ff       	call   80103d1c <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106354:	83 c4 10             	add    $0x10,%esp
80106357:	bb 20 94 12 80       	mov    $0x80129420,%ebx
8010635c:	81 fb 60 94 12 80    	cmp    $0x80129460,%ebx
80106362:	73 35                	jae    80106399 <setupkvm+0x6d>
                (uint)k->phys_start, k->perm) < 0) {
80106364:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106367:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010636a:	29 c1                	sub    %eax,%ecx
8010636c:	83 ec 08             	sub    $0x8,%esp
8010636f:	ff 73 0c             	pushl  0xc(%ebx)
80106372:	50                   	push   %eax
80106373:	8b 13                	mov    (%ebx),%edx
80106375:	89 f0                	mov    %esi,%eax
80106377:	e8 c1 f9 ff ff       	call   80105d3d <mappages>
8010637c:	83 c4 10             	add    $0x10,%esp
8010637f:	85 c0                	test   %eax,%eax
80106381:	78 05                	js     80106388 <setupkvm+0x5c>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106383:	83 c3 10             	add    $0x10,%ebx
80106386:	eb d4                	jmp    8010635c <setupkvm+0x30>
      freevm(pgdir);
80106388:	83 ec 0c             	sub    $0xc,%esp
8010638b:	56                   	push   %esi
8010638c:	e8 2b ff ff ff       	call   801062bc <freevm>
      return 0;
80106391:	83 c4 10             	add    $0x10,%esp
80106394:	be 00 00 00 00       	mov    $0x0,%esi
}
80106399:	89 f0                	mov    %esi,%eax
8010639b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010639e:	5b                   	pop    %ebx
8010639f:	5e                   	pop    %esi
801063a0:	5d                   	pop    %ebp
801063a1:	c3                   	ret    

801063a2 <kvmalloc>:
{
801063a2:	55                   	push   %ebp
801063a3:	89 e5                	mov    %esp,%ebp
801063a5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801063a8:	e8 7f ff ff ff       	call   8010632c <setupkvm>
801063ad:	a3 c4 44 13 80       	mov    %eax,0x801344c4
  switchkvm();
801063b2:	e8 48 fb ff ff       	call   80105eff <switchkvm>
}
801063b7:	c9                   	leave  
801063b8:	c3                   	ret    

801063b9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801063b9:	55                   	push   %ebp
801063ba:	89 e5                	mov    %esp,%ebp
801063bc:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801063bf:	b9 00 00 00 00       	mov    $0x0,%ecx
801063c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801063c7:	8b 45 08             	mov    0x8(%ebp),%eax
801063ca:	e8 f6 f8 ff ff       	call   80105cc5 <walkpgdir>
  if(pte == 0)
801063cf:	85 c0                	test   %eax,%eax
801063d1:	74 05                	je     801063d8 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801063d3:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801063d6:	c9                   	leave  
801063d7:	c3                   	ret    
    panic("clearpteu");
801063d8:	83 ec 0c             	sub    $0xc,%esp
801063db:	68 2e 6f 10 80       	push   $0x80106f2e
801063e0:	e8 63 9f ff ff       	call   80100348 <panic>

801063e5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, int pid)
{
801063e5:	55                   	push   %ebp
801063e6:	89 e5                	mov    %esp,%ebp
801063e8:	57                   	push   %edi
801063e9:	56                   	push   %esi
801063ea:	53                   	push   %ebx
801063eb:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801063ee:	e8 39 ff ff ff       	call   8010632c <setupkvm>
801063f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
801063f6:	85 c0                	test   %eax,%eax
801063f8:	0f 84 d1 00 00 00    	je     801064cf <copyuvm+0xea>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801063fe:	bf 00 00 00 00       	mov    $0x0,%edi
80106403:	89 fe                	mov    %edi,%esi
80106405:	3b 75 0c             	cmp    0xc(%ebp),%esi
80106408:	0f 83 c1 00 00 00    	jae    801064cf <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010640e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
80106411:	b9 00 00 00 00       	mov    $0x0,%ecx
80106416:	89 f2                	mov    %esi,%edx
80106418:	8b 45 08             	mov    0x8(%ebp),%eax
8010641b:	e8 a5 f8 ff ff       	call   80105cc5 <walkpgdir>
80106420:	85 c0                	test   %eax,%eax
80106422:	74 70                	je     80106494 <copyuvm+0xaf>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106424:	8b 18                	mov    (%eax),%ebx
80106426:	f6 c3 01             	test   $0x1,%bl
80106429:	74 76                	je     801064a1 <copyuvm+0xbc>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010642b:	89 df                	mov    %ebx,%edi
8010642d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    flags = PTE_FLAGS(*pte);
80106433:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106439:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    if((mem = kalloc(pid)) == 0)
8010643c:	83 ec 0c             	sub    $0xc,%esp
8010643f:	ff 75 10             	pushl  0x10(%ebp)
80106442:	e8 80 bc ff ff       	call   801020c7 <kalloc>
80106447:	89 c3                	mov    %eax,%ebx
80106449:	83 c4 10             	add    $0x10,%esp
8010644c:	85 c0                	test   %eax,%eax
8010644e:	74 6a                	je     801064ba <copyuvm+0xd5>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106450:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80106456:	83 ec 04             	sub    $0x4,%esp
80106459:	68 00 10 00 00       	push   $0x1000
8010645e:	57                   	push   %edi
8010645f:	50                   	push   %eax
80106460:	e8 32 d9 ff ff       	call   80103d97 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106465:	83 c4 08             	add    $0x8,%esp
80106468:	ff 75 e0             	pushl  -0x20(%ebp)
8010646b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106471:	50                   	push   %eax
80106472:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106477:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010647a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010647d:	e8 bb f8 ff ff       	call   80105d3d <mappages>
80106482:	83 c4 10             	add    $0x10,%esp
80106485:	85 c0                	test   %eax,%eax
80106487:	78 25                	js     801064ae <copyuvm+0xc9>
  for(i = 0; i < sz; i += PGSIZE){
80106489:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010648f:	e9 71 ff ff ff       	jmp    80106405 <copyuvm+0x20>
      panic("copyuvm: pte should exist");
80106494:	83 ec 0c             	sub    $0xc,%esp
80106497:	68 38 6f 10 80       	push   $0x80106f38
8010649c:	e8 a7 9e ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
801064a1:	83 ec 0c             	sub    $0xc,%esp
801064a4:	68 52 6f 10 80       	push   $0x80106f52
801064a9:	e8 9a 9e ff ff       	call   80100348 <panic>
      kfree(mem);
801064ae:	83 ec 0c             	sub    $0xc,%esp
801064b1:	53                   	push   %ebx
801064b2:	e8 f9 ba ff ff       	call   80101fb0 <kfree>
      goto bad;
801064b7:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
801064ba:	83 ec 0c             	sub    $0xc,%esp
801064bd:	ff 75 dc             	pushl  -0x24(%ebp)
801064c0:	e8 f7 fd ff ff       	call   801062bc <freevm>
  return 0;
801064c5:	83 c4 10             	add    $0x10,%esp
801064c8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801064cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064d5:	5b                   	pop    %ebx
801064d6:	5e                   	pop    %esi
801064d7:	5f                   	pop    %edi
801064d8:	5d                   	pop    %ebp
801064d9:	c3                   	ret    

801064da <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801064da:	55                   	push   %ebp
801064db:	89 e5                	mov    %esp,%ebp
801064dd:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801064e0:	b9 00 00 00 00       	mov    $0x0,%ecx
801064e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801064e8:	8b 45 08             	mov    0x8(%ebp),%eax
801064eb:	e8 d5 f7 ff ff       	call   80105cc5 <walkpgdir>
  if((*pte & PTE_P) == 0)
801064f0:	8b 00                	mov    (%eax),%eax
801064f2:	a8 01                	test   $0x1,%al
801064f4:	74 10                	je     80106506 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801064f6:	a8 04                	test   $0x4,%al
801064f8:	74 13                	je     8010650d <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801064fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064ff:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106504:	c9                   	leave  
80106505:	c3                   	ret    
    return 0;
80106506:	b8 00 00 00 00       	mov    $0x0,%eax
8010650b:	eb f7                	jmp    80106504 <uva2ka+0x2a>
    return 0;
8010650d:	b8 00 00 00 00       	mov    $0x0,%eax
80106512:	eb f0                	jmp    80106504 <uva2ka+0x2a>

80106514 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106514:	55                   	push   %ebp
80106515:	89 e5                	mov    %esp,%ebp
80106517:	57                   	push   %edi
80106518:	56                   	push   %esi
80106519:	53                   	push   %ebx
8010651a:	83 ec 0c             	sub    $0xc,%esp
8010651d:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106520:	eb 25                	jmp    80106547 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106522:	8b 55 0c             	mov    0xc(%ebp),%edx
80106525:	29 f2                	sub    %esi,%edx
80106527:	01 d0                	add    %edx,%eax
80106529:	83 ec 04             	sub    $0x4,%esp
8010652c:	53                   	push   %ebx
8010652d:	ff 75 10             	pushl  0x10(%ebp)
80106530:	50                   	push   %eax
80106531:	e8 61 d8 ff ff       	call   80103d97 <memmove>
    len -= n;
80106536:	29 df                	sub    %ebx,%edi
    buf += n;
80106538:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
8010653b:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106541:	89 45 0c             	mov    %eax,0xc(%ebp)
80106544:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106547:	85 ff                	test   %edi,%edi
80106549:	74 2f                	je     8010657a <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
8010654b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010654e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106554:	83 ec 08             	sub    $0x8,%esp
80106557:	56                   	push   %esi
80106558:	ff 75 08             	pushl  0x8(%ebp)
8010655b:	e8 7a ff ff ff       	call   801064da <uva2ka>
    if(pa0 == 0)
80106560:	83 c4 10             	add    $0x10,%esp
80106563:	85 c0                	test   %eax,%eax
80106565:	74 20                	je     80106587 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106567:	89 f3                	mov    %esi,%ebx
80106569:	2b 5d 0c             	sub    0xc(%ebp),%ebx
8010656c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106572:	39 df                	cmp    %ebx,%edi
80106574:	73 ac                	jae    80106522 <copyout+0xe>
      n = len;
80106576:	89 fb                	mov    %edi,%ebx
80106578:	eb a8                	jmp    80106522 <copyout+0xe>
  }
  return 0;
8010657a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010657f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106582:	5b                   	pop    %ebx
80106583:	5e                   	pop    %esi
80106584:	5f                   	pop    %edi
80106585:	5d                   	pop    %ebp
80106586:	c3                   	ret    
      return -1;
80106587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658c:	eb f1                	jmp    8010657f <copyout+0x6b>
